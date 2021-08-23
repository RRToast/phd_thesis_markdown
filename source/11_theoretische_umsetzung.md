# Theoretische Umsetzung
<!-- SCHRECK: (welches Konzept steckt dahinter, jeder Key hat einen Attestation Key, Protocol beschreibung, rekeying ) -->


<!-- was ich verstanden habe:
- jedes Keypair hat einen Attestation Key
- Account kann rekey werden, ob er das meinte weiß ich nicht
-->

## Aufbau der neuen ACME Challenge
Wie im Grundlagen Kapitel beschrieben ist die Challenge das Herzstück des ACME Protokolls. Ein Ziel dieser Bachelorarbeit besteht darin, eine neue Challenge zu erstellen. Dabei soll die gleiche Sicherheit mit POST und POST-as-GET Requests erzeugt werden und der Ablauf soll vergleichbar sein. Auch die Replay Noncen sollen weiterhin verwendet werden. Der Klassische Aufbau in dem erst ein Account erstellt wird, dann eine Challenge erzeugt, diese dann beantwortet und dann das Zertifikat mithilfe eines CSR erzeugt wird bleibt also erhalten. Die neue Challenge soll dabei eine Gerät Validierung und keine Domain validierung durchführen.

### Vorbereitung
Gegensätzlich zu den anderen beiden besprochenen Challenge Arten soll die neue Challenge die Kontrolle über das Gerät für welches sich der Client ausgibt, überprüfen. Der erste Schritt besteht darin entweder vom Hersteller oder per Hand den Public Key des EK aus dem TPM Chip zu erhalten. Der sogenannte EK ist ein fester Bestandteil des TPM Chips und wird bei dessen Erstellung vom Hersteller mit eingebaut. Der Private Teil kann dabei von außen weder ausgelsen werden, noch angefragt werden. Diese Tatsache wird verwendet um das Gerät eindeutig zu identifizieren. Der Öffentliche Teil des EK wird Serverseitig mit einer für dieses Gerät festgelegten Domain gespeichert. Dadurch kann der Server abgleichen ob eine Anfrage tatsächlich von einem Gerät kommt welches Serverseitig registiert ist und die Kommunikation frühzeitig beenden, falls das nicht der Fall ist.
<!-- TODO: ist die Domain ein wichtiger Teil dieser Arbeit? -->

### Account erstellen und verwalten
Das im Grundlagenkapitel beschrieben anfragen nach dem Directory, sowie die Verwendung von Replay-Noncen oder das erstellen des Accounts haben sich weder Clientseitig noch Serverseitig geändert. Die einzige Änderung die Vorgenommen werden kann, jedoch optional für den weiteren Ablauf der neuen Challenge ist, ist das erstellen des Privaten und Öffentlichen Schlüssels durch den TPM Chip. Dieses Schlüsselpaar kann für die Kommunikation mit JWS verwendet werden. Da der TPM Chip über eine Kryptographische Einheit verfügt kann sich der Client darauf verlassen, dass die so generierten Schlüssel sicher sind. Auf anderer Hardware wäre das zwar nicht so konsequent gewährleistet, allerdings kann in der heutigen Zeit davon ausgegangen werden, dass die meisten Prozessoren in der Lage sind vernünftige Schlüsselpaare zu generieren.
<!-- TODO: Erweitern um die Erklärung, dass jeder Account ein zugehöriges Keypair besitzt -->

### EK Challenge
Wie auch bei der DNS und HTTP Challenge besteht auch die neue EK Challenge aus zwei Teilen, erst dem Absenden der Order, dann dem Erfüllen der Challenge.
Für die Challenge wird Clientseitig mithilfe des TPM Chips ein sogenannter AK erstellt. Der *A*ttestation *K*ey wie er hier verwendet wird, ist ein Container der neben einem Öffentlichen Schlüssel auch Informationen wie die TPM Version, Create Attestation und einigen anderen besitzt. Dieser Key dient also nicht nur als normaler Schlüssel sondern vielmehr als eine Verpackung für Informationen über den TPM Chip, sowie Informationen zum erstellen eines Geheimnisses. Zusätzlich zu diesen Informationen die der AK beinhaltet ist es wichtig diesen zu erstellen, da der EK alleine, abhängig von der TPM Implementierung, eventuell nicht in der Lage ist selbst zu Verschlüsseln. Ziel dieser Verbindung aus EK und AK ist es, durch den EK das Gerät zu Identifizieren und durch ein Geheimniss, dass durch die Verwendung von EK und AK erstellt wird zu verifizieren. Das dabei verwendete Verfahren basiert auf einem Projekt von Google zur identifizierung von Geräten [@go-attestation].

Für die Order werden nun AK sowie EK zusammen als Value für den Identifier bestimmt, der Type trägt nun den Namen der neuen Challenge "ek". Abgesehen von dieser Änderung wird die Anfrage regulär an den Server gesendet. Dieser kann nun überprüfen ob der EK Wert in seiner Datenbank vorkommt. Falls nein wird dem Client ein 400 Fehler zurückgegeben, kommt der EK Value jedoch vor, kann nun mit der eigentlichen Challenge begonnen werden. Dazu erstellt der Server, unter Verwendung der AK und EK Werte ein Geheimniss.

Der Client kann daraufhin mit einem POST-as-GET Request dieses Geheimniss, sowie den vom Server für diesen Client zugeteilten domain Namen erfragen. Das Geheimniss kann nur mithilfe des TPM Chips entschlüsselt werden und das so gelöste Geheimniss wird wieder zurück and den Server gesendet. Wurde das Geheimniss korrekt entschlüsselt gilt die Challenge als erfüllt und der Server ändert den Status der Challenge von "pending" zu "processing" zu "valid". Dadurch wird sichergestellt, dass der Client die Kontolle über den TPM Chip besitzt. Die Prüfung der Identität des Client Geräts ist also eine Prüfung der Kontrolle über den entsprechenden TPM Chip.
<!-- TODO: Der AK kann jetzt verwendet werden um einen CSR zu erstellen und damit als Teil des Keypair für das Zertifikat gelten -->
<!-- TODO: ist die Domain ein wichtiger Teil dieser Arbeit? --> 

### CSR
Für die Erstellung des CSR verwendet der Client nun den TPM Chip, da dieser über einen eingebaute cryptographische Funktion verfügt und weil der Private Key nie auserhalb des Chips existieren darf. Der Public Key wird mit anderen Daten die in der CSR stehen sollen, darunter auch dem DNS Wert den der Server in der Datenbank hinterlegt hat, mit dem TPM Chip verschlüsselt. Diese Nachricht wird an den Server gesendet der das Zertifikat erstellt und dem Client zur Verfügung stellt, sodass dieser es per POST-as-GET Request abfragen kann.
Das so erhaltene Zertifikat wird nun auf dem TPM Chip gespeichert.

### Folge Anfragen
Der Client hat nun dem Server gegenüber bewiesen, dass dieser tatsächlich ist für wer er behauptet zu sein. Der Client kann nun, wenn eines seiner Zertifikate veraltet, einen Request zum erneuern <!-- TODO: wie könnte eine Folge Anfrage aussehen, welche Informationen hat der Server schon, was muss der Client noch beweisen? -->

## Erweiterungen
### Clientseitig
Der Client verfügt also über die Möglichkeit unter verwendung des TPM Chips ein Zertifikat vom spezifizierten ACME Server zu erhalten. Das gesammte Verfahren wäre nutzlos wenn es für einen Nutzer des Client Gerätes möglich wäre wertvolle Informationen aus dem Ablauf des neuen ACME Requests abzufangen. Es soll also eine zusätzliche Sicherheit geschaffen werden um das Client Gerät vor seinen eigenen Nutzern zu schüzten. Eine dem entsprechende Maßnahme ist, dass der Private Key welcher zum Zertifikat gehört den TPM nie verlässt. Aber auch Metadaten könnten für einen Angreifer interessant sein. Neben Böswilligen kann es auch fahrlässige Nutzer geben die schlicht vergessen ein Zertifikat anzufragen oder zu erneuern falls es veraltet. Aus all diesen Gründen wird ein System Daemon geschaffen, der die clientseitige Kommunikation mit dem ACME Server übernimmt. Dabei soll geprüft werden ob, erstens ein Zertifikat vorhanden ist, falls nein wird ein neues erstellt. Ist ein Zertifikat vorhanden, aber veraltet, oder läuft bald aus, so wird ein neues Zertifikat angefragt. Dadruch läuft die Kommunikation im Hintergrund ab und ist für den Nutzer des Gerätes unsichtbar. Zertifikate werden dem Nutzer durch den TPM Chip zur Verfügung gestellt.

### Serverseitig
Der ACME Server wird um die Funktionalität der Datenbank sowie der bearbeitung der Challenge erweitert. Dabei soll es einem Systemadministrator einfach gemacht werden die Liste der bekannten EK Public Keys zu erweitern und mit DNS Namen zu versehen. Auch Serverseitig gibt es Möglichkeiten wie der Umgang mit EK Werten sicherer gestaltet werden kann. So ist es möglich, sobald ein Client eine "ek" Challenge gestellt und bestanden hat, dessen Account mit dem entsprechendem EK Wert in der Datenbank zu verknüpfen. So kann immer eindeutig identifiziert werden, wenn ein neues Zertifikat erstellt wird, für welchen TPM dieses erstellt wurde. So ist es auch einfacher Zertifikate zu revoken, sollte das Gerät als gestohlen oder vermisst gemeldet werden, da nun diesem Datenbank Eintrag, mit all seinen Verknüpften Informationen nicht mehr vertraut werden kann.
<!-- TODO: auf jeden Fall nochmal ganz genau drüber lesen -->
