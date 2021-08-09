# Theoretische Umsetzung

## Aufbau der neuen ACME Challenge
Wie im Grundlagen Kapitel beschrieben ist die Challenge das Herzstück des ACME Protokolls. Das Ziel dieser Bachelorarbeit besteht darin, eine neue Challenge zu erstellen die sich an den anderen beiden Challenges orientiert. Es soll die gleiche Sicherheit mit POST und POST-as-GET Requests erzeugt werden und der Ablauf soll vergleichbar sein. Auch die Replay Noncen sollen weiterhin verwendet werden. Der Klassische Aufbau in dem erst ein Account erstellt wird, dann eine Challenge erzeugt, diese dann beantwortet und dann das Zertifikat mithilfe eines CSR erzeugt wird bleibt also erhalten.

### Vorbereitung
Gegensätzlich zu den anderen beiden Challenge Arten soll die neue Challenge Kontrolle über das Gerät für welches sich der Client ausgibt. Der erste Schritt besteht darin entweder vom Hersteller oder per Hand den Public Key des EK aus dem TPM Chip zu erhalten. Der sogenannte EK ist ein fester Bestandteil des TPM Chips und wird bei dessen Erstellung vom Hersteller mit eingebaut. Der Private Teil kann dabei von außen weder ausgelsen werden, noch angefragt werden. Diese Tatsache wird verwendet um das Gerät zu identifizieren. Der Öffentliche Teil des EK wird Serverseitig mit einer für dieses Gerät festgelegten Domain gespeichert. Dadurch kann der Server abgleichen ob eine Anfrage tatsächlich von einem Gerät kommt welches Serverseitig registiert ist und die Kommunikation frühzeitig beenden, falls das nicht der Fall ist.

### Account erstellen und verwalten
Die Kommunikation zum erstellen und verwalten des Accounts läuft ab wie im Grundlagenkapitel beschrieben, hier ändert sich für den Client so wie für den Server nichts.

### Challenge
Die Challenge besteht aus zwei Teilen, erst dem Absenden der Order, dann dem Erfüllen der Challenge.
Für die Challenge wird Clientseitig ein sogenannter AK erstellt, dass ist wichtig, da der EK abhängig von der TPM Implementierung eventuell nicht in der Lage ist selbst zu Verschlüsseln. AK sowie EK werden nun zusammen als Value für den Identifier bestimmt, der Type trägt nun den Namen der neuen Challenge, hier wurde "ek", als Wert gewählt. Abgesehen von dieser Änderung wird die Anfrage regulär an den Server gesendet. Dieser kann nun überprüfen ob der EK Wert in seiner Datenbank vorkommt. Falls nein wird dem Client ein 400 Fehler zurückgegeben, kommt der EK Value jedoch vor, kann nun mit der eigentlichen Challenge begonnen werden. Dazu erstellt der Server, unter Verwendung der AK und EK Werte ein Geheimniss.

Der Client kann daraufhin mit einem POST-as-GET Request dieses Geheimniss, sowie die dazugehörige domain name erfragen. Das Geheimniss kann mithilfe des TPM Chips entschlüsselt werden und wird entschlüsselt wieder zurück and den Server gesendet. Wurde das Geheimniss korrekt entschlüsselt gilt die Challenge als erfüllt und der Server ändert den Status der Challenge von "pending" zu "processing" zu "valid", falls das Geheimniss richtig ist. Dadurch wird sichergestellt, dass der Client Kontolle über den TPM Chip besitzt. Die Prüfung der Identität des Client Geräts ist also eine Prüfung des TPM Chips.

### CSR
Für die Erstellung des CSR verwendet der Client nun den TPM Chip, da dieser über einen eingebaute cryptographische Funktion verfügt und weil der Private Key diesen Chip nicht verlassen darf. Der Public Key wird nun mit anderen Daten die in der CSR stehen sollen, darunter auch der DNS Wert den der Server in der Datenbank hinterlegt hat, mit dem TPM Chip verschlüsselt. Diese Nachricht wird an den Server gesendet der das Zertifikat erstellt und dem Client zur Verfügung stellt, sodass dieser es per POST-as-GET Request abfragen kann.
Das so erhaltene Zertifikat wird nun auf dem TPM Chip gespeichert.

## Erweiterung des ACME Protokolls
### Clientseitig
Hier muss zuallererst die Kommunikation zwischen Gerät und TPM Chip ermöglicht werden. Anschließend wird ein System Deamon geschaffen in dem der ACME Client verbaut ist. Dieser Daemon wird teil des Boot prozesses des Servers und überprüft das aktuelle Zertifikat. Ist keins Vorhanden wird ein neuer Account erstellt und eine Order aufgegeben. Diese Kommunikation läuft im Hintergrund ab und ist für den Nutzer des Gerätes unsichtbar. Wurde erfolgreich ein Zertifikat erhalten, wird dieses im TPM Chip gespeichert und dem Nutzer so zur Verfügung gestellt.

### Serverseitig
Der ACME Server wird um die Funktionalität der Datenbank sowie der bearbeitung der Challenge erweitert. Dabei soll es einem Systemadministrator einfach gemacht werden die Liste der bekannten EK Public Keys zu erweitern und mit DNS Namen zu versehen. 
