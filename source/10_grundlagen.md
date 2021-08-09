# Grundlagen

## TPM Chip
Das TPM ist ein Chip mit dem Funktionen der Sicherheit auf einer Physischen Ebene umgesetzt werden sollen. Auch wenn der Chip erstmals 2009 von der International Organization for Standardization (ISO) und International Electrotechnical Commission (IEC) [@tpm_iso2009] beschrieben wurde, existierten bereits 2011 300 Millionen dieser Chips[@a_formal_analysis_of_authentication_in_the_tpm]. Eine Zahl die mit der Ankündigung von Windows, für ihr neues Betriebsystem Windows 11 TPM2.0 Chips als Anforderung zu stellen, warscheinlich weiter steigen wird[@heise_tpm_windows]. Die Idee des TPM Chips ist dabei die Limitationen und Probleme die sicherheits Software und standartmäßige Hadware haben zu beheben. Darunter fallen unsicherer Speicher, volatiler Speicher sowie unsichere Kryptographische Hadware. So können Sensible Daten auf dem gesicherten persistenten Speicher des Chips abgespeichert werden. Zusätzlich stellt der Chip neben dem Speicher auch eine Kryptographische Einheit zur Verfügung, die es dem Chip erlaubt durch verschiedene cryptographische Verfahren, Schlüssel zu erzeugen so wie Informationen zu ver- und entschlüsseln. Zu verwendung des Chips verfügt dieser über eine eigene umfassende API. Die Funkionalitäten und Funktionsweisen des Chips sind dabei auf über 700 Seiten Dokumentation zusammengefasst[@a_formal_analysis_of_authentication_in_the_tpm]. Für diese Arbeit reicht es zu verstehen, dass der Chip, je nach gewähltem Verfahren ein Schlüsselpaar erstellt kann indem nur der Public Key aus dem Chip gelesen werden kann, der Private Key diesen jedoch, da er im Chip erstellt und direkt im gesicherten Speicher gespeichert wird, nie verlässt. Diese Tatsache kann verwendet werden um das Gerät welchen den TPM Chip verwendet an diesem zu identifizieren. Jeder Chip verfügt über einen sogenannten Endorsment Key. Dabei handelt es sich um drei Teile: einen private Key im gesicherten Speicher auf den nicht zugegriffen werden kann, einen public Key auf den zugegriffen werden kann, sowie ein Certifikat welches vom Hersteller signiert wurde.[@a_practical_guide_to_tpm] An diesem Certifikat in Verbindung mit dem ensprechendem private Key kann der TPM Chip eindeutig identifiziert werden.

(TODO: MARKIEREN 1:1 aus A Formal Analysis of Authenticationin the TPM)

## Raspberrypi
Der Raspberrypi ist ein kleiner vollwertiger Computer. Er wird hier einerseits verwendet, da nichts vorinstalliert oder eingerichtet wurde, andererseits stellt der Pi Pins zur Verfügung an denen ein TPM Chip installiert werden kann.
Wie bereits angedeutet gibt es bereits eine vergleichbare Lösung für Windows Systeme, also wird ein Linuxsystem verwendet werden. Der Raspberrypi stellt also die Grundlage für ein System auf dem das Verfahren entwickelt werden soll.

## ACME
ACME steht für *A*utomatic *C*ertificate *M*anagement *E*nviroment, also eine Automatische Zertifikats Management Umgebung. Diese besteht aus zwei Teilen: erstens einer CA welche Zertifikate austellt und verwaltet und zweitens einer automatisierten Schnittstelle welche erst prüft ob Anfragen valide sind und diese dann an die CA weiter gibt. Dadurch können Zertifikate Automatisch anzufragen werden. Dazu wird auf dem Gerät welches ein Zertifikat benötigt ein ACME Client ausgeführt, welcher eine Anfrage an den entsprechenden ACME Server stellt. Dieser prüft dann mit sogenannten Challenges, dass der Client tatsächlich ist für den er sich ausgibt. Ist der Client in der Lage die Challenge zu erfüllen kann dieser ein Zertifikat anfragen. Dieses Prinzip soll sich für diese Bachelorarbeit zu nutze gemacht werden. Auch hier soll mit einem Automatisierten Verfahren erst eine Prüfung des Client getätigt werden und dann ein Zertifikat ausgestellt werden.
Der ACME Server arbeitet dabei mit einer Datenbank in der jeder Client der ein Zertifikat anfragen möchte erstmal einen Account erstellen muss. Für diesen Account kann der Client dann Anfragen nach Zertifikaten schicken, muss dabei jedoch für jede Anfrage eine Challenge erfüllen. Die Art der Challenge, ob nun DNS oder HTTPS kann der Client dabei frei wählen.

### Hintergrund
Ein ACME Server der nicht gleichzeitig als Webserver dient muss laut RFC-8555 mindestens eine Schnittstelle zur Verfügung stellen, die unverschlüsselt erreicht werden kann. Diese dient als Directory und Übersicht über alle URLs die benötigt werden, damit der Client mit dem Server Kommunizieren kann. Darunter finden sich unter anderem URLs um ein Certifikat zu widerrufen, eine Replay-Nonce zu erhalten und einen Account zu erstellen. Jede Kommunikation mit Ausnahme des GET-Requests zum erhalten des Directroys sowie dem erhalten der Replay-Nonce ist verschlüsselt und muss mit einer Replay-Nonce abgesichert werden. Dabei übersendet der Server bei jeder Anfrage des Client auch eine Replay Nonce im Header des Responses mit, sodass diese nicht jedes mal neu angefragt werden muss. Jede Kommunikation, ausgenommen der genannten zwei, muss als POST oder POST-as-GET Request durchgeführt werden. POST-as-GET bedeutet, dass jede Anfrage die normalerweise ein GET-Request wäre, nun als POST Request mit leerem, aber Verschlüsseltem body, geschickt wird.

POST-as-GET Requests sind unabdingbar, da jede Kommunikation durch JWS gesichert ist. Die Schlüsselpaare die für die Kommunikation notwendig sind müssen vor Vorher Clientseitig erstellt werden.
<!-- TODO: soll ich den Abastz umformulieren?
                    | newNonce   | New nonce          |
                    |            |                    |
                    | newAccount | New account        |
                    |            |                    |
                    | newOrder   | New order          |
                    |            |                    |
                    | newAuthz   | New authorization  |
                    |            |                    |
                    | revokeCert | Revoke certificate |
                    |            |                    |
                    | keyChange
-->

### Ablauf
Folgend soll der Typische Ablauf einer ACME Kommunikation von der ersten Nachricht, bis zum erhalten des Zertifikates dargestellt werden. Der grundsätzliche Ablauf des ACME Protokolls ändert sich abhängig davon ob der Client bereits über ein Account auf dem Server verfügt. Hier wird jedoch davon ausgegangen, dass Client und Server noch keinerlei Kontakt mit einander hatten. Der einfachheit halber wird die Kommunikation aus sicht des Clients dargestellt und die internen Ablaufe des ACME Servers, da sie von Server zu Server unterschiedlich sein können, außer acht gelassen.
Zu allererst muss der Client eine Anfrage an das Directory stellen um zu erfahren welche URL für welche Kommunikation benötigt wird. Sind die URLs bereits bekannt, kann dieser vorbereitungs Schritt übersprungen werden.


#### Die erste Nonce
Die Nonce wird im weiteren Ablauf des Protokolls in jedem Response des Servers mitgeschickt, damit der Client nicht wieder eine neue Anfragen senden muss. Dadurch entsteht eine Kette die aus Anfrage des Clients mit erhaltener Nonce und Antwort des Servers mit neuer Nonce besteht. Wenn die Nonce jedoch abgelaufen ist, da die letzte Kommunikation länger zurückgliegt, oder der Client noch garkeine Anfrage gestellt hat und somit noch garkeine Nonce erhalten hat, kann der Client eine neue Nonce Anfragen. Dazu schickt der Client einen HEAD Request an den Server an die über das Directroy erhaltene URL. Da jede Kommunikation die nun beschrieben wird eine Replay-Nonce verwendet wurde darauf verzichtet dies immer wieder anzuführen.
<!--
TODO: Soll ich hier ein Beispiel oder Bild einfügen?
-->
Bilder können mit der folgenden Syntax eingefügt werden:
![Bildunterschrift \label{mein_label}](source/figures/AblaufGetNonce.png){ width=90% }


#### Account erstellen
Jeder Request wird fest an einen Account gebunden und so muss ein neuer Account erstellt werden. Dazu sendet der Client in seiner JWS Payload Mailaddressen die mit diesem Account verknüpft werden sollen, sowie eine Bestätigung das der Client mit den Nutzungsbedinugen einverstanden ist an den Server. Optional kann hier auch ein bereits vorhandenes Konto verknüpft werden. Da noch keine KID vorhanden ist wird hier im Header an dessen Stelle JWK mit dem entsprechendem Privaten Schlüssel an den Server gesendet.
Der Server antwortet in der Payload mit dem Status des Accounts, sowie mit der KID des Client und der entsprechenden URL des Accounts.

#### Order platzieren
Mit den im letzten Schritt erhaltenen Informationen kann der Client nun eine Order aufgeben. Dazu sendet er in der Payload ein Array mit allen Ordern die er aufgeben möchte, sowie einen Zeitlichen Rahmen in dem die Validierung durchgeführt werden soll, an den Server. Dabei wird in dem Array nicht nur definiert mit welchem Verfahren sondern auch mit gegen welchen Wert die Validierung stattfinden soll.
In der Antwort schickt der Server den Status, wann die Anfrage ungültig wird, sowie ein Array an Links zur Validierung der Order. Für jede Order wird ein Link erstellt. Zusätzlich antwortet der Server mit einer Finalisierungs URL die im späteren Verlauf benötigt wird.

#### Challenge aktivieren
Je nachdem welchen Challenge Typ es geht, ist dieser Schritt unterschiedlich. Bei der DNS Challenge wird nun eine Nachricht an den Server geschickt um ihn wissen zu lassen das jetzt eine Validierung durchgeführt werden kann. Der Server antwortet mit einem Wert den der Client entschlüsselt in einem TXT Dokument, für den Server zugänglich abspeichert. Der Server kann nun dieses Dokument anfragen und so bestimmen das der Client tatsächlich die Kontrolle über die angegebene DNS besitzt.

#### Challenge erfüllen
Auch dieser Schritt ist abhängig von der jeweiligen Challenge, grob kann gesagt werden, dass die Challenge erfüllt wird und der Server den Status für diese Challenge anpasst. Erst wenn der Status der Challenge von "pending" zu "processing" und abschließend zu valid geändert wird, kann der Client hierfür ein

#### CSR wird an den Server geschickt
Ist der Status für diese Order als Valide gesetzt, also wurden alle Challenges erfüllt, so kann der Client sein Certifikat anfragen. Dazu sendet er dem Server eine CSR, welcher dieser verwendet um ein Certifkat zu erstellen.

#### Certifikat wird erhalten
Das im vorherigen Schritt erstellte Zertifikat wird auf dem Server gespeichert und kann vom Client angefordert werden. Dazu sendet dieser einen POST-as-GET Request an die im letzten Schritt mitgeteilte URL. Der Server Antwortet mit dem Certifiat im Body der Antwort.

#### Weitere mögliche Schritte
Damit ist die Kommunikation abgeschlossen. Der Client kann nun über den erstellten Account die Certifikate aktualisieren lassen, ohne die Challenges noch einmal durchlaufen zu müssen. Der Client kann den Server bitten den Account zu löschen oder ein Certifikat zu wiederrufen.
