# Praktische Umsetzung \label{praktisch}

## Architektur
![Vereinfachte Darstellung des Client Server Aufbaus \label{clientServer}](source/figures/ClientServer.png){width=90%}

### Einrichtung des ACME Client
Für die Einrichtung des ACME Client sind zwei Voraussetzungen notwendig. Einmal dass der Client auf einem Linux System läuft, welche Linux distribution dabei verwendet wird ist egal. Und andererseits die korrekte Installation des TPM Chips. Hierbei gibt es zwei Möglichkeiten wie der Chip installiert werden kann. So ist es möglich den Chip Physisch an dem jeweiligen Gerät, entsprechend seiner Anleitung zu befestigen und einzurichten. Der Chip kann aber auch auf dem Client Gerät simuliert werden, welche Simulation dabei verwendet wird ist dem Architekten des Systems überlassen. Hierbei muss jedoch beachtet werden dass die Sicherheit wie in den vorangegangen Kapiteln beschrieben, nur durch den physischen Chip garantiert werden kann. Da der Chip immer nur eine Kommunikation gleichzeitig erlaubt muss sichergestellt werden, dass kein anderes Programm gerade mit diesem Kommuniziert und eine Kommunikation so blockiert. Ein einfacher Test in Linux sieht folgendermaßen aus
```shell
$ sudo cat /dev/tpm0
```
Antwortet der TPM Chip mit "resource is busy" blockiert ein anderer Prozess. Vor allem bei Geräten auf denen bereits mit dem Chip gearbeitet wurde muss darauf geachtet werden. In der hier beschrieben Praktischen Umsetzung wurde ein Physischer TPM Chip und keine Emulation oder Simulation verwendet.

### Aufsetzen des ACME Servers
Hierfür wurde sich bereits existierender Software bedient. Pebble ist ein ACME Server der von letsencrypt zur Verfügung gestellt wird[@pebble]. Dabei handelt es sich um eine Vereinfachte Version die für Testzwecke, aber nicht auf live Systemen verwendet werden sollte. Diese stellt alle grundlegenden Funktionen die für die folgenden Schritte benötigt werden zur Verfügung. Einzig ein persistenter Datenspeicher muss hierfür erstellt werden. Da es sich um ein Proof-of-Concept handelt wurden die EK Werte, gegen die getestet werden soll, statt in einer realen Datenbank, in go Programmen hartcodiert. Wichtig ist hierbei nur das die Werte persistent gespeichert sind und der Server diese abfragen kann.
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
Das Projekt wurde sowohl Serverseitig wie auch Clientseitig in GO geschrieben. Als Server wurde mein eigener Rechner Verwendet, der Client lief auf einem Raspberrypi, der Code für beide wurde vorrangig auf dem Rechner geschrieben. Die IP Adressen sind beispielhafte Werte. Hierbei soll aufgezeigt werden, wie die Kommunikation zum ACME Server ermöglicht wird und darauf aufbauend, wie die neue EK Challenge implementiert und verwendet werden kann. Die verwendeten Bilder sollen dabei als visuelle Stütze dienen und sind nicht ausreichend um das Projekt nachzubauen.

### Implementierung des regulären ACME Ablaufs
Wie bereits in den Grundlagen beschrieben, bedient sich die Kommunikation zwischen dem Client und Server Replay-Noncen sowie JWS. Um die Replay Nonce zu erhalten reicht es einen HEAD Request an die von Pebble für diesen Zweck bereitgestellt Schnittstelle zu senden. Der Aufbau dieser Methode ist unabhängig von der Art der Challenge und gilt so für EK genauso wie für DNS und HTTP.
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
In dieser Methode wird zuallererst geprüft ob bereits einen Nonce, hier globNonce genannt, vorhanden ist. Falls nein, wird ein Request ausgesendet und der Response Header für die Replay-Nonce ausgelesen. Der erste Test ist deshalb wichtig, da im Folgenden Ablauf jede Antwort des Servers eine neue Nonce übersandt, welche den Wert von globNonce annimmt. So muss der Client nicht nach jeder Kommunikation erst eine neue Nonce vom Server erfragen.

Zum Signieren der Nachrichten wird Clientseitig ein Schlüsselpaar generiert. Wie im Theoretischen Teil bereits besprochen ist Sinnvoll das Schlüsselpaar vom TPM Chip generieren zu lassen. Beispielcode aus der Methode für den Account erstellungs Request:
```go
var signerOpts = jose.SignerOptions{NonceSource: dummyNonceSource{}}
signerOpts.WithHeader("jwk", jose.JSONWebKey{Key: globPrivateKey.Public()})
signerOpts.WithHeader("url", signMeUpURL)
signer, err := jose.NewSigner(jose.SigningKey{Algorithm: jose.RS256,
	Key: globPrivateKey}, &signerOpts)
if err != nil {
  panic(err)
}
```
Nur dieser Request wird der Öffentlichen Schlüssel verschickt. Im späteren Verlauf, sobald der Account erstellt wurde, wird anstelle von "jwk" die "kid" die vom Server mitgeteilt wurde verwendet. Durch diesen Request ist der Server nicht nur in der Lage einen neuen Account zu erstellen, sondern kann auch den entsprechenden Öffentlichen Schlüssel diesem Account zuordnen. Da alle Nachrichten als POST Request verschickt werden, kann durch die Signatur geprüft werden ob es sich dabei um den gleichen Absender handelt wie bei vorangegangen Nachrichten.

### Erweiterung des ACME Protokolls um die neue Challenge

#### Order platzieren
Nachdem der Client registriert ist kann dieser ein neues Zertifikat anfragen. Dazu soll die neu definierte EK Challenge verwendet werden. Dazu stellt der Client eine Verbindung mit dem Chip her und liest so den Public Key des EK aus und lässt sich einen AK erstellen. Für beide Funktionalitäten kann auf das Projekt "go-attestation" [@go-attestation] von Google zurückgegriffen werden. Der AK besitzt sogenannte Attestation Parameter, die später vom Server verwendet werden können. Diese Informationen werden nun an den Server gesendet, dazu wird der Wert des "identifier" mit dem "type":"ek" und "value" :"[ek+ak]" gesetzt.

![getOrder Body \label{orderbody}](source/figures/ACMEGetOrderBody.png)

So sieht der Request des Get Order requests aus, welcher an den Server gesendet wird.
Um mit dem neuen Identifier etwas anfangen zu können muss der Server um den Identifier, sowie die neue "ek-01" Challenge erweitert werden:

```go
const (
	[...]

	IdentifierDNS = "dns"
	IdentifierIP  = "ip"
	IdentifierEK  = "ek"  // <-

	ChallengeHTTP01    = "http-01"
	ChallengeTLSALPN01 = "tls-alpn-01"
	ChallengeDNS01     = "dns-01"
	ChallengeEK        = "ek-01" // <-

	HTTP01BaseURL = ".well-known/acme-challenge/"

	ACMETLS1Protocol = "acme-tls/1"
)
```

![Erweiterung der Challenge datenbank des Servers \label{serverdb}](source/figures/pebbleIdentifier.png){ width=90% }

Nun kann bereits die erste Prüfung stattfinden. Ist der EK Wert dem Server nicht bekannt, stimmt also nicht mit dem Hart Codierten Wert überein, so wird dem Client hier schon ein Fehler zurückgegeben und die Kommunikation endet. Die einzige Möglichkeit für den Client diesen Schritt zu meistern ist also über einen korrekten öffentlichen Schlüssel des EK Werts zu Verfügen.

#### Challenge aktivieren
Der Server erkennt, dass es sich um eine "ek" Identifier handelt und die einzige Challenge die dem Client für diesen Identifier zur Verfügung steht, ist die "ek-01" Challenge. Als Vorbereitung für diese Challenge benötigt der Server das Geheimniss, folgend als Secret bezeichnet, welches er zur Überprüfung des Clients verwenden kann. Dazu werden die Werte, welche der Client im AK übersendet hat zusammen mit dem Wert des EK verwendet um das Secret zu erstellen.
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
Im Gegensatz zur HTTP oder DNS Challenge in denen der Client den Server nun aktiv werden lässt, muss hier der Client selber das entschlüsselte Geheimniss an den Server senden. Dieser Prüft nun ob der Wert des gelösten Geheimnisses dem erwarteten Wert entspricht und entscheidet so, ob die Challenge erfolgreich erfüllt wurde oder nicht. Dieser Prozess der Überprüfung, sowie das aktualisieren des Statuses der Challenge kann einige Minuten dauern. Deshalb wird hier ein einfacher polling Mechanismus verwendet. Dazu wird ein Status abfragender Request im zwei Sekunden takt so lange an den Server gesendet, bis dieser den Status der Challenge geändert hat.
<!-- TODO: Bild einfügen -->

#### CSR und Zertifikat
Da der private Key den Chip nicht verlassen darf, ist es notwendig, das der CSR über den TPM Chip generiert wird. Informationen, wie der Name oder die Mail adresse sind natürlich selbst ausfüllbar. Ein Request wird nun an den Server gesendet mitsamt der CSR, wobei der Server überprüft, ob der Wert des im CSR beschriebenen Öffentlichen Schlüssels mit dem des AK übereinstimmt. Ist das der Fall, so stellt der Server das Zertifikat aus. Der Client kann es sich nun per GET-as-POST Request abholen.
Das einzige, dass der Client jetzt noch zu erledigen hat, ist es das Zertifikat für den Benutzer des Client Systems auf dem TPM Chip zur Verfügung zu stellen.
<!-- TODO: Auch hier Bild einfügen -->
