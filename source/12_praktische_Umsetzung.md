# Praktische Umsetzung

## Architektur

### Einrichtung des ACME Clients
Für die Einrichtung des ACME Clients sind zwei Vorraussetzungen notwendig. Einmal dass der Client auf einem Linux System läuft, welche Linux distribution dabei verwendet wird ist jedoch egal. Und andererseits die Korrekte installation des TPM Chips. Hierbei gibt es zwei Möglichkeiten wie der Chip installiert werden kann. So ist es möglich den Chip Physisch an dem jeweiligen Gerät, entsprechend seiner Anleitung zu befestigen und einzurichten. Oder den Chip auf dem Client Gerät zu simulieren, welche Simulation dabei verwendet wird ist dem Architekten des Systems überlassen. Hierbei muss jedoch beachtet werden dass die Sicherheit wie in den vorrangegangen Kapiteln beschrieben nur durch den Physischen Chip garantiert werden kann. Um den Chip verwenden zu können muss sichergestellt werden das kein anderes Programm gerade mit diesem Kommuniziert und eine Kommunikation so blockiert. Ein einfacher Test in Linux ist folgender:
```shell
sudo cat /dev/tpm0
```
Antwortet der TPM Chip mit "ressource is busy" blockiert ein anderer Prozess. Vor allem bei Geräten auf denen bereits mit dem Chip gearbeitet wurde muss hierauf geachtet werden.

### Aufsetzen des ACME Servers
Hierfür wurde sich bereits exisiterender Software bedient. Pebble ist ein ACME Server der von letsencrypt zur Verfügung gestellt wird. Dabei handelt es sich um eine leichte Version die für Testzwecke aber nicht auf Live Systemen verwendet werden soll. Diese Stellt alle grundlegenden Funktionen die für die Folgenden Schritte benötigt werden zur Verfügung. Einzig eine Datenbank muss hierfür erstellt werden. Welche Form diese annimmt ist jedoch wieder dem Architekten überlassen. Da es sich hier nur um ein Proof-of-Concept handelt wurden die Zertifikate, welche in der Datenbank stehen in go Programmen hartkodiert.
```go
const pubPEM = `
-----BEGIN RSA PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAh2oOFWso2nWgrA/6SIcJ
xznL4ZHw1rVnphcqYVChhzC8tXdZ6eZmPWbIP4xgKtZsYSAkPbo1Lf3dPFlA+G5W
xuXpE5QRn1bIo3Rx0CxLwduy/z7Eak8HNI32eb1U2jPYqCMCeLRStNjNnqZEoji4
//cqss1B1pXWJCH8VckfpSiXBvA+0Jyk5ceY83VCVYoKBwLVhRnTEFI2TeWUOFDn
136c85//Yd+Mohx9aoTyYTiC84ePO/sJoNdKaFl8JjgsqxYPFxcCguzeCacvA/Jr
Ps853EG0Sl52FuBj21CeB8QJUrNpabT/kFM9kBW6HQvWEgASvO0FTJ42lCx80Ecv
mQIDAQAB
-----END RSA PUBLIC KEY-----`
```


## Implementierung
Das Projekt wurde sowohl Serverseitig wie auch Clientseitig in GO geschrieben. Als Server wurde mein eigenener Rechner Verwendet, der Client lief auf einem Raspberrypi, der Code für beide wurde vorrangig auf dem Rechner geschrieben. Die IP Addressen sind beispielhafte Werte.

### Implementierung des regulären ACME Ablaufs
Wie bereits in den Grundlagen beschrieben bedient sich die Kommunikation zwischen dem Client und Server sogenannten Replay-Noncen sowie JWS.
Um die Replay Nonce zu erhalten reicht es einen HEAD Request an die von Pebble für diesen Zweck bereit gestellt Schnittstelle zu senden.
```go
func (n dummyNonceSource) Nonce() (string, error) {
	if globNonce != "" {
		return globNonce, nil
	}
	tr := &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}
	client := &http.Client{Transport: tr}

	res, err := client.Head("https://192.168.1.2:14000/nonce-plz")
	if err != nil {
		panic(err)
	}
	ua := res.Header.Get("Replay-Nonce")
	return ua, nil
}
```
In dieser Methode wird zuallererst geprüft ob bereits einen Nonce, hier globNonce genannt, vorhanden ist. Falls nein, wird ein Request ausgesendet und der Response Header für die Replay-Nonce ausgelesen.

Zum Signieren der Nachrichten wird Clientseitig ein Schlüsselpaar generiert. Beispielcode aus der Methode für den Account erstellungs Request:
```go
var signerOpts = jose.SignerOptions{NonceSource: dummyNonceSource{}}
signerOpts.WithHeader("jwk", jose.JSONWebKey{Key: globPrivateKey.Public()})
signerOpts.WithHeader("url", signMeUpURL)
signer, err := jose.NewSigner(jose.SigningKey{Algorithm: jose.RS256, Key: globPrivateKey}, &signerOpts)
if err != nil {
  panic(err)
}
```
Nur dieser Request übersendet den Public key. Im späteren Verlauf, sobald der Account erstellt wurde, wird anstelle von "jwk" die "kid" die vom Server mitgeteilt wurde verwendet.

### Erweiterung des ACME Protokolls um die neue Challenge

#### Order platzieren
Nachdem der Client registriert ist kann dieser ein neues Zertifikat anfragen, dazu soll die neu definerte "ek" Challenge verwendet werden. Dazu liest der Client den Public Key des EK aus dem TPM Chip und lässt sich einen AK erstellen. Für die Erstellung des AK, sowie das auslesen des EK Wertes wird auf das Projekt "go-attestation" [@go-attestation] von Google zurückgegriffen. Der AK besitzt sogennte Attestation Parameter, die später vom Server verwendet werden können. Diese Informationen werden nun an den Server gesendet, dazu wird der Wert des "identifier" mit dem "type":"ek" und "value" :"[ek+ak]" gesetzt.
(todo: Bilder einfügen)
Nun kann der Request an den Server gesendet werden.
Um mit dem neuen Identifier etwas anfangen zu können muss der Server um den Identifier, sowie die neue "ek-01" Challenge erweitert werden:
![Get Request des Clients \label{mein_label}](source/figures/pebbleIdentifier.png){ width=90% }
*erweiterung der Pebble Identifier*
Hier findet bereits die erste Prüfung statt. Ist der EK Wert dem Server nicht bekannt, steht also nicht in der Datenbank, so wird dem Client hier schon ein Fehler zurückgegeben und die Kommunikation endet hier. Die einzige Möglichkeit für den Client diesen Schritt zu meistern ist also über einen korrekten EK Wert zu Verfügen.

#### Challenge aktivieren
Der Server erkennt, dass es sich um eine "ek" Identifier handelt und die einzige Challenge die dem Client für diesen Identifier zur Verfügung steht, ist die "ek-01" Challenge. Als Vorbereitung für diese Challenge benötigt der Server das Geheimniss, folgend als Secret bezeichnet, welches er zur überprüfung des Clients verwenden kann. Dazu werden die Werte welche der Client im AK übersendet hat zusammen mit dem Wert des EK verwendet um das Secret zu erstellen.
```go
params := attest.ActivationParameters{
	TPMVersion: attest.TPMVersion20,
	AK: attest.AttestationParameters{

		Public:            bpublic,
		CreateData:        bcreateData,
		CreateAttestation: bcreateAttestation,
		CreateSignature:   bcreateSignature,
	},
	EK: getEkPublicKey(ek),
}
secret, encryptedCredentials, err := params.Generate()
if err != nil {
	panic(err)
}
```
das "b" vor public, createData, CreateAttestation und CreateSignature welche aus AK extrahiert wurden gibt dabei an, dass es sich jeweils um byte Werte handelt. Das so erstellt Secret wird nun dem Client auf seinen Post-as-Get Request zum erhalten der Challenge zur verfügung gestellt.
Der Client muss nun nur noch die Challenge mit dem in "go-attestation" beschriebenen Verfahren lösen.

#### Challenge erfüllen
Im Gegensatz zur HTTP oder DNS Challenge in denen der Client den Server nun aktiv werden lässt muss der Client nun selber das entschlüsselte Geheimniss an den Server senden. Dieser Prüft nun ob der Wert des gelösten Geheimnisses dem erwarteten Wert entspricht und entscheidet so ob die Challenge erfolgreich erfüllt wurde oder nicht.
<!-- TODO: weiter ausführen, vielleicht code mit einfügen -->

#### CSR wird an den Server geschickt

#### Certifikat wird erhalten
