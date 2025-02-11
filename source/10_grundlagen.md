# Grundlagen

## TPM
Das TPM ist ein Chip mit dem Funktionen der Sicherheit auf einer physischen Ebene umgesetzt werden sollen. Auch wenn der Chip erstmals 2009 von der International Organization for Standardization (ISO) und International Electrotechnical Commission (IEC) ^[@tpm_iso2009, Seite 33-35] beschrieben wurde, existierten bereits 2011 300 Millionen dieser Chips ^[see @a_formal_analysis_of_authentication_in_the_tpm, pp. 33-35 and *passim*] . Eine Zahl die mit der Ankündigung von Windows, für ihr neues Betriebsystem Windows 11 TPM2.0 Chips als Anforderung zu stellen, wahrscheinlich weiter steigen wird[@heise_tpm_windows]. Die Idee des TPM Chips ist dabei die Limitationen und Probleme die sicherheits Software und standardmäßige Hardware haben zu beheben. Darunter fallen unsicherer Speicher, volatiler Speicher sowie unsichere kryptographische Hardware. So können Sensible Daten auf dem gesicherten persistenten Speicher des Chips gespeichert werden. Zusätzlich stellt der Chip neben dem Speicher auch eine kryptographische Einheit zur Verfügung, die es dem Chip erlaubt durch verschiedene kryptographische Verfahren, Schlüssel zu erzeugen, so wie Informationen zu ver- und entschlüsseln. Zur Verwendung des Chips verfügt dieser über eine eigene umfassende API. Die Funktionalitäten und Funktionsweisen des Chips sind dabei auf über 700 Seiten Dokumentation zusammengefasst[@a_formal_analysis_of_authentication_in_the_tpm]. Für diese Arbeit reicht es zu verstehen, dass der Chip, je nach gewähltem Verfahren ein Schlüsselpaar erstellen kann und es nur möglich ist, den Public Key aus dem Chip zu lesen, der Private Key diesen jedoch, da er im Chip erstellt und direkt im gesicherten Speicher abgespeichert wird, nie verlässt. Diese Tatsache kann verwendet werden um das Gerät welches den TPM Chip verwendet an diesem zu identifizieren. Jeder Chip verfügt über einen sogenannten Endorsement Key. Dabei handelt es sich um drei Teile: einen private Key im gesicherten Speicher auf den nicht zugegriffen werden kann, einen public Key auf den zugegriffen werden kann, sowie ein Zertifikat welches vom Hersteller signiert wurde.[@a_practical_guide_to_tpm] An diesem Zertifikat in Verbindung mit dem entsprechenden private Key kann der TPM Chip eindeutig identifiziert werden.

<!-- (TODO: MARKIEREN 1:1 aus A Formal Analysis of Authenticationin the TPM),    TODO: etwas mehr auf die Architektur eingehen -->

## ACME
ACME steht für *A*utomatic *C*ertificate *M*anagement *E*nviroment, also eine Automatische Zertifikats Verwaltungs Umgebung. Diese besteht aus zwei Teilen: erstens einer CA welche Zertifikate erstellt und verwaltet und zweitens einer automatisierten Schnittstelle welche erst prüft ob Anfragen valide sind und diese dann an die CA weiter gibt. Dadurch können Zertifikate automatisch angefragt werden. Dazu wird auf dem Gerät welches ein Zertifikat benötigt ein ACME Client ausgeführt, welcher eine Anfrage an den entsprechenden ACME Server stellt. Dieser prüft dann mit sogenannten Challenges, dass der Client tatsächlich ist für den er sich ausgibt. Ist der Client in der Lage die Challenge zu erfüllen kann dieser ein Zertifikat anfragen. Dieses Prinzip soll sich für diese Bachelorarbeit zu nutze gemacht werden. Auch hier soll mit einem automatisierten Verfahren erst der Client geprüft und anschließend ein Zertifikat ausgestellt werden.
Der ACME Server arbeitet dabei mit einer Datenbank in der jeder Client der ein Zertifikat anfragen möchte erstmal einen Account erstellen muss. Für diesen Account kann der Client dann Anfragen nach Zertifikaten schicken, muss dabei jedoch für jede Anfrage eine Challenge erfüllen. Die Art der Challenge, ob nun DNS oder HTTPS kann der Client dabei frei wählen.
<!-- (TODO: Der Folgende Teil orientiert sich sehr stark am RFC-8555 wie markiere ich das? Wo schreibe ich das am besten auf um nicht unabsichtlich ein Plagiat zu haben?) -->

### Hintergrund
Ein ACME Server der nicht gleichzeitig als Webserver dient muss laut RFC-8555 mindestens eine Schnittstelle zur Verfügung stellen, die unverschlüsselt erreicht werden kann. Diese dient als Directory und Übersicht über alle URLs die benötigt werden, damit der Client mit dem Server kommunizieren kann. Darunter finden sich unter anderem URLs um ein Zertifikat zu widerrufen, eine Replay-Nonce zu erhalten und einen Account zu erstellen. Jede Kommunikation mit Ausnahme des GET-Requests zum erhalten des Directorys sowie dem erhalten der Replay-Nonce ist verschlüsselt und muss mit einer Replay-Nonce abgesichert werden. Dabei übersendet der Server bei jeder Anfrage des Client auch eine Replay Nonce im Header des Responses mit, sodass diese nicht jedes mal neu angefragt werden muss. Jede Kommunikation, ausgenommen der genannten zwei, muss als POST oder POST-as-GET Request durchgeführt werden. POST-as-GET bedeutet, dass jede Anfrage die normalerweise ein GET-Request wäre, nun als POST Request mit leerem, aber signiertem body, geschickt wird. POST-as-GET Requests sind unabdingbar, da jede Kommunikation durch JWS gesichert muss und der Body des GET Requests keine definierte Form hat[@rfc-7231]. Die Schlüsselpaare die für die Kommunikation mit JWS notwendig sind müssen vorher clientseitig erstellt werden.

### Ablauf
Folgend soll der Ablauf einer ACME Kommunikation von der ersten Nachricht, bis zum erhalten des Zertifikates dargestellt werden. Der grundsätzliche Ablauf des ACME Protokolls ändert sich abhängig davon ob der Client bereits über ein Account auf dem Server verfügt. Hier wird jedoch davon ausgegangen, dass Client und Server noch keinerlei Kontakt miteinander hatten. Der einfachheit halber wird die Kommunikation aus sicht des Clients dargestellt und die internen Abläufe des ACME Servers, da sie von Server zu Server unterschiedlich sein können, außer acht gelassen.
Zu allererst muss der Client eine Anfrage an das Directory stellen um zu erfahren welche URL für welche Kommunikation benötigt wird. Sind die URLs bereits bekannt, kann dieser vorbereitende Schritt übersprungen werden.

![Bildunterschrift \label{mein_label}](source/figures/dnshttpAblauf.png)

#### Die erste Nonce
Die Nonce wird im weiteren Ablauf des Protokolls in jedem Response des Servers mitgeschickt, damit der Client nicht wieder eine neue Anfragen nur für die Replay Nonce senden muss. Dadurch entsteht eine Kette die aus Anfrage des Clients mit erhaltener Nonce und Antwort des Servers mit neuer Nonce besteht. Wenn die Nonce jedoch abgelaufen ist, da die letzte Kommunikation länger zurückliegt, oder der Client noch gar keine Anfrage gestellt hat und somit noch keine Nonce erhalten hat, kann der Client eine neue Nonce Anfragen. Dazu schickt der Client einen HEAD Request an den Server an die über das Directory erhaltene URL. Da jede Kommunikation die nun beschrieben wird eine Replay-Nonce verwendet, wurde darauf verzichtet dies immer wieder anzuführen.
<!-- TODO: Soll ich hier ein Beispiel oder Bild einfügen? -->
![Bildunterschrift \label{mein_label}](source/figures/AblaufGetNonce.png){ width=90% }
*RFC8555 Get Nonce beispiel*


#### Account erstellen
Jede Order wird fest an einen Account gebunden und so muss zu Beginn ein neuer Account erstellt werden. Dazu sendet der Client in seiner JWS Payload Mail Adressen, die mit diesem Account verknüpft werden sollen, sowie eine Bestätigung dass der Client mit den Nutzungsbedingungen einverstanden ist an den Server. Optional könnte in diesem Schritt auch ein bereits vorhandenes Konto verknüpft werden. Da noch keine KID vorhanden ist wird hier im Header an dessen Stelle der JWK mit dem entsprechendem Öffentlichen Schlüssel der zum Signieren verwendet wurde an den Server gesendet.
Der Server antwortet in der Payload mit dem Status des Accounts, sowie mit der Account URL, welche im folgenden Ablauf als KID fungiert.
![Get Request des Clients \label{mein_label}](source/figures/AblaufGetAccount.png){ width=90% }
*RFC8555 New Account beispiel*

![Get Request des Clients \label{mein_label}](source/figures/AblaufGetAccountResponse.png){ width=90% }
*RFC8555 New Account Server Antwort beispiel*

#### Order platzieren
Mit den im letzten Schritt erhaltenen Informationen kann der Client nun eine Order erstellen. Dazu sendet er in der Payload ein identifier Array mit allem was er validiert haben möchte. In diesem Array wird nicht nur definiert mit welchem Verfahren (type) sondern auch gegen welchen Wert(value) die Validierung stattfinden soll. Der Client kann sich aussuchen wie er geprüft werden möchte, die prominentesten zwei Verfahren die DNS sowie die HTTP Challenge werden im nächsten Schritt näher erläutert. Für beide übersendet der Client in im type des identifier den Wert "dns" mit.
Zusätzlich kann der Client bestimmen für welchen Zeitraum das Zertifikat gültig sein soll durch das übersenden von "notBefore" und "notAfter" Werten, das ist jedoch optional.
In der Antwort schickt der Server den Status, wann die gültigkeit der Anfrage ausläuft, sowie ein Array an Links zur Validierung der Order mit. Für jeden identifier mit type und value wird genau ein Link erstellt, im sogenannten authorizations Array. Zusätzlich antwortet der Server mit einer finalize URL die im späteren Verlauf benötigt wird.

#### Challenge aktivieren
Für den Client gibt es mehrere Arten auf die der Server validieren kann, dass er tatsächlich ist wer er vorgibt zu sein. Im RFC-8555 Dokument werden dabei zwei näher erläutert, die auch hier ausführlicher besprochen werden sollen. Die HTTP, sowie die DNS Challenge. Weiterführend gibt es Erweiterungen für das Dokument wie eine Challenge die die IP Adresse prüft [@rfc-8738] oder die Domain über TLS prüfen [@rfc-8737]. Um zu verstehen wie ACME funktioniert, reicht es jedoch sich auf die DNS sowie die HTTP Challenge zu beschränken.

Der Client sendet nun einen POST-as-GET Request an den Server, an die URL dessen challenge er als erstes bearbeiten möchte.
Der Server antwortet nun mit Informationen zu dieser Challenge wie dem Status, wann sie abläuft, dem entsprechenden Identifier Werten und einem Array mit Challenges. Diese Challenges haben den type "http-01" oder "dns-01". Beide haben eine eigene url, sowie einen gemeinsamen token. Der Token ist dabei ein zufälliger base64 Wert, der die Challenge eindeutig identifiziert.

DNS Challenge:
Der Client kann aus diesem Token, in Verbindung mit seinem eigenen Account Key einen Authorisierungsschlüssel (Authorization Key) erstellen. Dieser Schlüssel wird anschließend mit dem SHA-256 Verfahren verschlüsselt (hashed). Dieser Wert wird nun base64 encoded und in einem TXT Dokument gespeichert. Dieses Dokument wird dabei unter der im Identifier Value angegebenen Domain unter dem Prefix "_acme-challenge" abgespeichert. Für "www.example.org" wird die Datei also unter "_acme-challenge.www.example.org" abgespeichert [@rfc-8555]. Der Client sendet nun einen POST-as-GET Request zum Server um diesen zu informieren, das dieser die Datei anfragen kann.

HTTP Challenge:
Die http-01 Challenge läuft sehr ähnlich ab. Hier wird genauso ein Autorisierungsschlüssel erstellt. Nur wird dieser Schlüssel unter "[domain]/.well-known/acme-challenge/[token]" für einen GET Request zur Verfügung gestellt.

#### Challenge erfüllen
Nun sendet der Client eine POST-as-GET Request an den Server um ihn wissen zu lassen, dass er nun mit der Validierung beginnen kann. Um zu validieren, dass die Challenge erfüllt wurde erstellt der Server den selben Hash, frägt von der Domain das TXT Dokument oder die HTTP Ressource an und überprüft dass der erhaltene Wert mit dem eigenen Werte übereinstimmt. Ist das gelungen, gilt die Challenge als bestanden.
<!--TODO: soll ich hier Vor und Nachteile ausführen?
Der große Vorteil dieser Challenge ist, das sogenannte WildCard Zertifikate ausgestellt werden können. Das heißt, dass der Client nicht für jede Subdomain eine eigene Anfrage mit Challenge stellen muss sondern alles für eine Domain validiert werden kann. Der Nachteil besteht allerdings darin, dass die DNS Challenge im Vergleich zur HTTP Challenge deutlich komplizierter aufzusetzen ist. (TODO: Vor und Nachteile ausführen, vielleicht mit Pros und Cons von hier: https://letsencrypt.org/docs/challenge-types/ ) -->



<!-- TODO: Hier entweder mehr schreiben oder zusammenfassen, gilt für jeden Punkt --> 
#### CSR wird an den Server geschickt
Ist der Status für diese Order als Valide gesetzt, also wurden alle Challenges erfüllt, so kann der Client sein Zertifikat anfragen. Dazu sendet er dem Server eine CSR an die finalize URL. Anhand dieser CSR erstellt nun der Server das Zertifikat und übersendet dem Client in der Antwort unter anderem die certificate URL, den Ort an dem das Zertifikat zur Verfügung steht, mit.

#### Zertifikat wird erhalten
Um das Zertifikat anzufordern muss der Client jetzt nur noch einen POST-as-GET Request an die im letzten Schritt mitgeteilte URL senden. Der Server Antwortet mit dem Certifiat im Body der Antwort.

#### Weitere mögliche Schritte
Damit ist die Kommunikation abgeschlossen. Der Client kann nun über den erstellten Account die Zertifikate aktualisieren lassen, ohne die Challenges noch einmal durchlaufen zu müssen. Der Client kann den Server bitten den Account zu löschen oder ein Zertifikat zu widerrufen.
