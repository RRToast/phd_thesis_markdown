# Umsetzung

## Architektur

### Einrichtung des Raspberry Pi inklusive TPM Chip
Hierbei gilt sich an das Einrichten des Rapsberry Pi sowie die Anweisung des TPM Chips zur installation zu halten. Dazu wurde zuerst eine Linux distribution auf dem Raspberry installiert. Dadurch kann der Chip, sobald er Physisch am Bord befestigt wird ebenfalls installiert werden. In diesem Schritt der Einrichtung der Hardware muss nur sichergestellt werden, dass die Kommunikation mit dem TPM Chip nicht durch andere Prozesse blockiert wird. Ein einfacher Test wäre
```shell
sudo cat dev/tpm0
```
Antwortet der TPM Chip mit "ressource is busy" blockiert ein anderer Prozess. Vorallem bei Geräten auf denen bereits mit dem Chip gearbeitet wurde muss hierauf geachtet werden.

### Aufsetzen des ACME Servers
Hierfür wurde sich bereits exisiterender Software bedient. Pebble ist ein ACME Server der von letsencrypt zur Verfügung gestellt wird. Dabei handelt es sich um eine leichte Version die für Testzwecke aber nicht auf Live Systemen verwendet werden kann. Diese Stellt alle Grundlegenden Funktionen die für die Folgenden Schritte benötigt werden zur Verfügung.


## Implementierung
Das Projekt wurde sowohl Serverseitig wie auch Clientseitig in GO geschrieben. Als Server wurde mein eigenener Rechner Verwendet, der Client lief auf dem Raspberrypi, der Code für beide wurde vorrangig auf dem Rechner geschrieben. Die IP Addressen sind beispielhafte Werte.

### Implementierung des regulären ACME Ablaufs
Wie bereits in den Grundlagen beschrieben bedient sich die Kommunikation zwischen dem Client und Server Replay Noncen sowie JWS.
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
In dieser Methode wird zuallererst geprüft ob bereits einen Nonce, hier globNonce genannt, vorhanden ist. Falls nein wird ein Request ausgesendet und der Response Header für die Replay-Nonce ausgelesen.

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

#### Vorbereitungen
Da Pebble nur über eine Volatile Datenbank verfügt und es sich nur um einen Proof of concept handelt wurde der Öffentliche Teil des EK Hard in den Server gecodet. Serverseitig müssen keine weiteren Vorbereitungen getroffen werden.
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

#### Order platzieren
Um den TPM Chip verifizieren zu können wird der Public Key des EK aus dem TPM Chip gelesen und auch mithilfe des Chips ein AK erstellt. Dazu wird auf das Projekt go-attestation von Google zurückgegriffen. Der AK besitzt sogennte Attestation Parameters, die später vom Server verwendet werden können.
Um diese Information zusammen mit der Art der zu verwenden Challenge zu verschicken, wird ein "identifier" mit dem "type":"ek" und "value" :"[ek+ak]" gesetzt.
(todo: Bilder einfügen)

#### Challenge aktivieren

#### Challenge erfüllen

#### CSR wird an den Server geschickt

#### Certifikat wird erhalten

<!--
## Einleitung

Das ist die Einleitung. Nam mollis congue tortor, sit amet convallis tortor mollis eget. Fusce viverra ut magna eu sagittis. Vestibulum at ultrices sapien, at elementum urna. Nam a blandit leo, non lobortis quam. Aliquam feugiat turpis vitae tincidunt ultricies. Mauris ullamcorper pellentesque nisl, vel molestie lorem viverra at.

## Methode

Suspendisse iaculis in lacus ut dignissim. Cras dignissim dictum eleifend. Suspendisse potenti. Suspendisse et nisi suscipit, vestibulum est at, maximus sapien. Sed ut diam tortor.

### Unterabschnitt 1 mit Beispielcode

Das ist der erste Teil der Methodik. Cras porta dui a dolor tincidunt placerat. Cras scelerisque sem et malesuada vestibulum. Vivamus faucibus ligula ac sodales consectetur. Aliquam vel tristique nisl. Aliquam erat volutpat. Pellentesque iaculis enim sit amet posuere facilisis. Integer egestas quam sit amet nunc maximus, id bibendum ex blandit.

Syntaxhervorhebung in Codeblöcken erreicht man mit drei "`" Zeichen vor und nach dem Codeblock.

```python
mood = 'happy'
if mood == 'happy':
    print("I am a happy robot")
```

### Unterabschnitt 2

Das ist der zweite Teil der Methodik. Proin tincidunt odio non sem mollis tristique. Fusce pharetra accumsan volutpat. In nec mauris vel orci rutrum dapibus nec ac nibh. Praesent malesuada sagittis nulla, eget commodo mauris ultricies eget. Suspendisse iaculis finibus ligula.

<!--
Kommentare können so hinzugefügt werden.

## Ergebnisse

Das sind die Ergebnisse. Ut accumsan tempus aliquam. Sed massa ex, egestas non libero id, imperdiet scelerisque augue. Duis rutrum ultrices arcu et ultricies. Proin vel elit eu magna mattis vehicula. Sed ex erat, fringilla vel feugiat ut, fringilla non diam.

## Auseinandersetzung

Das ist die Auseinandersetzung mit den Ergebnissen. Duis ultrices tempor sem vitae convallis. Pellentesque lobortis risus ac nisi varius bibendum. Phasellus volutpat aliquam varius. Mauris vitae neque quis libero volutpat finibus. Nunc diam metus, imperdiet vitae leo sed, varius posuere orci.

## Schlussfolgerung

Das ist die Schlussfolgerung des Kapitels. Praesent bibendum urna orci, a venenatis tellus venenatis at. Etiam ornare, est sed lacinia elementum, lectus diam tempor leo, sit amet elementum ex elit id ex. Ut ac viverra turpis. Quisque in nisl auctor, ornare dui ac, consequat tellus.

-->
