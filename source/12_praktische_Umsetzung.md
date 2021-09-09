# Praktische Umsetzung \label{praktisch}
Im folgenden Kapitel soll beschrieben werden, wie unter Zuhilfenahme der Informationen aus den letzten zwei Kapiteln eine Implementierung des Verfahrens realisiert wurde. Dazu wurde dieses Kapitel in zwei Teile eingeteilt. Im ersten Teil soll der Aufbau des Systems aus Linux-basiertem Client mit zugehörigem TPM-Chip und Server mit zugehöriger Datenbank besprochen werden. Im zweiten Teil geht es um die Implementierung des Verfahrens, die anhand von ausgewählten Codebeispielen erklärt werden soll.

## Architektur
Wie in Abbildung \ref{clientServer} verdeutlicht werden soll, handelt es sich bei der Lösung um zwei miteinander kommunizierende Parteien, den ACME-Server und den ACME-Client. Bei dem ACME-Server handelt es sich um eine inhaltliche Erweiterung für ein bereits existierenden ACME-Server sowie das Erweitern eines Datenspeichers. Auf der Clientseite steht ein Linux-System, das auf einen TPM-Chip zugreifen kann.

![Vereinfachte Darstellung des Client-Server-Aufbaus \label{clientServer}](source/figures/ClientServer.png){width=90%}

### Einrichtung des ACME-Client
Für die Einrichtung des ACME-Client müssen zwei Voraussetzungen erfüllt sein: Erstens, dass der Client auf einem Linux-System läuft, wobei gleichgültig ist, welche Linux-Distribution verwendet wird, zweitens die korrekte Installation des TPM-Chips. Hierbei gibt es zwei Möglichkeiten, wie der Chip installiert werden kann. So ist es möglich, den Chip an dem jeweiligen Gerät entsprechend der Anleitung physisch zu befestigen und einzurichten. Der Chip kann aber auch auf dem Client-Gerät simuliert werden. Welche Simulation dabei verwendet wird, ist dem Architekten des Systems überlassen. Es muss jedoch beachtet werden, dass die Sicherheit, wie sie in den vorangegangen Kapiteln beschrieben wurde, nur durch den physischen Chip garantiert werden kann. Da der Chip immer nur eine Kommunikation gleichzeitig erlaubt, muss sichergestellt werden, dass kein anderes Programm gerade mit diesem kommuniziert und eine Kommunikation auf diese Weise blockiert. Ein einfacher Test in Linux sieht folgendermaßen aus:

\begin{lstlisting}[caption={Schnellcheck für die TPM Erreichbarkeit}, captionpos=b]
$ sudo cat /dev/tpm0
\end{lstlisting}

Erhält man auf diese Anfrage die Antwort "resource is busy", wird der TPM-Chip durch einen anderen Prozess blockiert. In der hier beschrieben praktischen Umsetzung wurde ein physischer TPM-Chip und keine Emulation oder Simulation verwendet.

### Aufsetzen des ACME-Servers
Für diese Arbeit wurde sich bereits existierender Software bedient. "Pebble" ist ein ACME-Server, der von "letsencrypt" zur Verfügung gestellt wird[@pebble]. Dabei handelt es sich um eine vereinfachte Version, die für Testzwecke, aber nicht auf live-Systemen verwendet werden sollte. Diese stellt alle grundlegenden Funktionen, die für die folgenden Schritte benötigt werden, zur Verfügung. Einzig ein persistenter Datenspeicher muss hierfür erstellt werden. Da es sich um ein Proof-of-Concept handelt, wurden die EK-Werte, gegen die getestet werden soll, statt in einer realen Datenbank in GO-Programmen hartkodiert, wie im folgenden Listing zu sehen ist. Wichtig ist nur, dass die Werte persistent gespeichert sind und der Server diese abfragen kann.

\begin{lstlisting}[caption={EK öffentlicher Schlüssel, wfe.go}, captionpos=b]
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
\end{lstlisting}

## Implementierung
Das Projekt wurde sowohl server- wie auch clientseitig in der Programmiersprache "GO" geschrieben. Als Server wurde der eigene Rechner verwendet, der Client lief auf einem Raspberry PI, der Code für beide wurde vorrangig auf dem Rechner geschrieben. Die IP-Adressen sind beispielhafte Werte, die nur dazu dienen um aufzuzeigen, wie die Kommunikation zum ACME-Server ermöglicht wird und, darauf aufbauend, wie die neue EK-Challenge implementiert und verwendet werden kann. Die verwendeten Bilder sollen dabei als visuelle Stütze dienen und sind nicht ausreichend, um das Projekt nachzubauen.

### Implementierung des regulären ACME-Ablaufs
Wie bereits in den Grundlagen beschrieben, bedient sich die Kommunikation zwischen dem Client und dem Server Replay-Noncen sowie JWS. Um die Replay-Nonce zu erhalten, reicht es, einen HEAD-Request an die von "Pebble" für diesen Zweck bereitgestellte Schnittstelle zu senden. Der Aufbau dieser Methode ist unabhängig von der Art der Challenge und gilt somit für EK genauso wie für DNS und HTTP und wird im folgenden Listing beschrieben.

\begin{lstlisting}[caption={clientseitige Beschaffung der Noncen, encryption.go}, captionpos=b]
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
\end{lstlisting}

In der hier beschriebenen Methode wird zuallererst geprüft, ob bereits eine Nonce, hier "globNonce" genannt, vorhanden ist. Falls nicht, wird ein Request ausgesendet und der Response-Header für die Replay-Nonce ausgelesen. Der erste Schritt ist deshalb wichtig, da im folgenden Ablauf jede Antwort des Servers eine neue Nonce übersendet, die den Wert von "globNonce" überschreibt. So muss der Client nicht nach jeder Kommunikation erst eine neue Nonce vom Server erfragen.

Zum Signieren der Nachrichten wird clientseitig ein Schlüsselpaar generiert. Wie im theoretischen Teil bereits besprochen, ist es sinnvoll, das Schlüsselpaar vom TPM-Chip generieren zu lassen. Beispielcode aus der Methode für den Kontoerstellungs-Request:

\begin{lstlisting}[caption={Anfrage zum Erstellen eines neuen Kontos, encryption.go}, captionpos=b]
var signerOpts = jose.SignerOptions{NonceSource: dummyNonceSource{}}
signerOpts.WithHeader("jwk", jose.JSONWebKey{Key: globPrivateKey.
	Public()})
signerOpts.WithHeader("url", signMeUpURL)
signer, err := jose.NewSigner(jose.SigningKey{Algorithm: jose.RS256,
	Key: globPrivateKey}, &signerOpts)
if err != nil {
  panic(err)
}
\end{lstlisting}

Nur in diesem Request, das im Listing "Anfrage zum erstellen eines neuen Kontos" beschrieben wird, wird der öffentliche Schlüssel verschickt. Im späteren Verlauf, sobald das Konto erstellt wurde, wird anstelle von "jwk" die "kid", die vom Server mitgeteilt wurde, verwendet. Durch diesen Request ist der Server nicht nur in der Lage, ein neues Konto zu erstellen, sondern kann auch den entsprechenden öffentlichen Schlüssel diesem Konto zuordnen. Da alle Nachrichten als POST-Request verschickt werden, kann durch die Signatur geprüft werden, ob es sich dabei um den gleichen Absender handelt wie bei vorangegangen Nachrichten.

### Erweiterung des ACME-Protokolls um die neue Challenge
Die neue Challenge umfasst wie die anderen Challenges auch drei Schritte. Erst muss eine Order beim Server aufgegeben werden, dann muss die Challenge aktiviert und anschließend erfüllt werden. Dieser Prozess, zusammen mit dem Anfragen und Verwenden des Zertifikates, soll in diesem Unterkapitel beschrieben werden. Die Idee hinter jeder Änderung bezieht sich dabei auf den im theoretischen Teil beschriebenen Ablauf.

#### Order platzieren
Nachdem der Client registriert ist, kann dieser ein neues Zertifikat anfragen. Dazu soll die neu definierte EK-Challenge verwendet werden, wofür der Client eine Verbindung mit dem Chip herstellt und so den öffentlichen Schlüssel des EK ausliest und sich einen AK erstellen lässt. Für beide Funktionalitäten kann auf das Projekt "go-attestation" [@go-attestation] von "Google" zurückgegriffen werden. Der AK besitzt sogenannte Attestation Parameter, die später vom Server verwendet werden können. Diese Informationen werden nun an den Server gesendet. Dazu wird der Wert des "identifier" mit dem "type":"ek" und "value":"[ek+ak]" gesetzt. Der Body des Get-Order-Requests, der an den Server gesendet wird, sieht so aus:

\begin{lstlisting}[caption={Server Antwort auf Challenge Anfrage}, captionpos=b]
{
	"status": "pending",
	"expires": "2021-08-24T13:32:22Z",
	"identifiers": [
		{
			"type": "ek",
			"value": "{\KeyEncoding\":2,\TPMVersion\":2,
				[...]
				-----END RSA PUBLIC KEY-----\n"
		}
	],
	"finalize": "https://192.168.1.8:14000/finalize-order/dn3VRQ7wgq
	oe7Gu6xnAZQCdRRAbeyKWqoqnloxYsuWs",
	"notBefore": "2021-08-01T00:04:00+04:00",
	"notAfter": "2021-08-08T00:04:00+04:00",
	"authorizations": [
		"https://192.168.1.8:14000/authZ/nQxyaQV942uQoT1AFeM
		FRaFpGQUZ7MiZB_HmK-xAJK4"
	]
}
\end{lstlisting}


Um mit dem neuen "identifier" etwas anfangen zu können, muss der Server um den Identifier sowie die neue "ek-01"-Challenge erweitert werden. Das folgende Codebeispiel soll dabei beispielhaft für die gesamte Implementierung der neuen "identifier" gelten:

\begin{lstlisting}[caption={Serverseitiger Eintrag der neuen Identifier}, captionpos=b]
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
\end{lstlisting}

Nun kann bereits die erste Prüfung stattfinden. Ist der EK-Wert dem Server nicht bekannt, stimmt dieser also nicht mit dem hartkodierten Wert überein, so wird dem Client hier schon ein Fehler zurückgegeben und die Kommunikation endet. Die einzige Möglichkeit für den Client, diesen Schritt zu meistern, ist also über den korrekten öffentlichen Schlüssel des EK-Werts zu verfügen.

#### Challenge aktivieren
Der Server erkennt, dass es sich um einen "ek"-Identifier handelt, und die einzige Challenge, die dem Client für diesen Identifier zur Verfügung steht, ist die "ek-01"-Challenge. Als Vorbereitung für diese Challenge benötigt der Server das Geheimnis, im folgenden Codebeispiel als Secret bezeichnet, welches er zur Überprüfung des Clients verwenden kann. Dazu werden die Werte, die der Client im AK übersendet hat, zusammen mit dem Wert des EK verwendet, um das Geheimnis zu erstellen.

\begin{lstlisting}[caption={Geheimnis (secret) Erstellung, wfe.go}, captionpos=b]
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
\end{lstlisting}

In dem vorangegangen Codebeispiel wird die Generierung des Geheimnisses auf der Serverseite dargestellt. Das "b" vor "public", "createData", "CreateAttestation" und "CreateSignature", die jeweils aus dem AK extrahiert wurden, gibt dabei an, dass es sich um byte-Werte handelt. Das so erstellte Geheimnis kann der Client mithilfe eines POST-as-GET-Request abfragen. Der Client muss nun nur noch die Challenge mit dem in "go-attestation" beschriebenen Verfahren lösen.

#### Challenge erfüllen
Im Gegensatz zur HTTP- oder DNS-Challenge, in denen der Client den Server nun aktiv werden lassen würde, muss hier der Client selbst das entschlüsselte Geheimnis an den Server senden. Dieser prüft nun, ob der Wert des gelösten Geheimnisses dem erwarteten Wert entspricht, und entscheidet so, ob die Challenge erfolgreich erfüllt wurde oder nicht. Dieser Prozess der Überprüfung, sowie das Aktualisieren des Status der Challenge kann einige Minuten dauern. Deshalb wird hier ein einfacher Polling-Mechanismus verwendet. Dazu wird ein den Status abfragender Request im Zwei-Sekunden-Takt so lange an den Server gesendet, bis dieser den Status der Challenge geändert hat.

#### CSR und Zertifikat
Da der private Schlüssel den Chip nicht verlassen darf, ist es notwendig, dass der CSR über den TPM-Chip generiert wird. Informationen wie der Name oder die Mailadresse sind natürlich selbst ausfüllbar. Ein Request wird nun mitsamt der CSR an den Server gesendet, wobei der Server überprüft, ob der Wert des im CSR beschriebenen öffentlichen Schlüssels mit dem des AK übereinstimmt. Ist das der Fall, so stellt der Server das Zertifikat aus. Der Client kann es sich nun per POST-as-GET-Request abholen.
Das Einzige, was der Client jetzt noch zu erledigen hat, ist das Zertifikat für den Benutzer des Client-Systems auf dem TPM-Chip zur Verfügung zu stellen.
