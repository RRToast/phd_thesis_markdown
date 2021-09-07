# Evaluation
Die Evaluation soll zeigen, ob die in dieser Arbeit besprochenen Erweiterungen funktionieren und eine sinnvolle Erweiterung des RFC8555 sind. Gleichzeitig soll überprüft werden, ob das Ziel dieser Arbeit, das sichere Verteilen von X.509-Zertifikaten auf Linux-basierten Endbenutzersystemen, erfüllt wurde. Dazu soll zuerst ein Testlauf mit den entsprechenden Ergebnissen dargestellt werden, anschließend wird die neue Challenge mit vorherigen Challenges verglichen und auf mögliche Angriffsvektoren, welche durch die in dieser Arbeit beschriebenen Vorgehen aufkommen, sowie mögliche sinnvolle Erweiterungen eingegangen wird.

## Testlauf der ACME-Erweiterung
Um die ACME-Erweiterung zu testen, wurde auf dem eigenen Rechner der ACME-Server und auf einem Raspberry PI mit TPM-Chip der Client ausgeführt. Ziel des Ablaufes war es sicherzustellen, dass die im praktischen Teil beschrieben client- und serverseitigen Erweiterung wie geplant funktionieren. Darunter gehören Funktionalitäten wie das Anlegen eines Kontos, das Erstellen und Verwenden der neuen Challenge, die Identifizierung des Endbenutzersystems, sowie die neue Art CSR zu erstellen. Im Folgenden wird der Output der Clientseitigen implementiert dargestellt. Der Status 400 wird erhalten, da Serverseitig die entsprechenden Informationen noch nicht zur Verfügung stehen. Wie man sehen kann wird hier die Nachricht "authChallenge: POST-as-GET request to retreive challenge details" mehrfach ausgegeben. Das liegt an der Umsetzung des Polling-Verfahrens, das den Status so lange abfragt, bis dieser "valid" ist.
```go
start
newAccount: Account created!

HTTP result status:  201 Created
newCertificate: New Certificate requested!

HTTP result status:  200 OK
authChallenge: POST-as-GET request to retreive challange details

The payload with secret looks like this: 0x86c600
HTTP result status:  200 OK
authChallengeAnswer: Challenge answer was send!

HTTP result status:  400 Bad Request
authChallenge: POST-as-GET request to retreive challange details

Value ist : 400
HTTP result status:  200 OK
authChallenge: POST-as-GET request to retreive challange details

Value ist : "pending"
HTTP result status:  200 OK
authChallenge: POST-as-GET request to retreive challange details

Value ist : "valid"
HTTP result status:  200 OK
makeCSRRequest: CSR Request send!

HTTP result status:  200 OK
downloadCertificate: Get URL

HTTP result status:  200 OK
POST-as-GET request to retreive Certificate
```
*Listing 5.1: Ablauf der neuen Challenge*

## Ergebnisse
Der Output beschreibt den Ablauf des ACME-Protokolls, erweitert um die "ek"-Challenge. Am Ende dieser Kommunikation befindet sich im TPM-Chip das Zertifikat, das für einen Benutzer des Client-Geräts zugänglich gespeichert wurde, sowie dessen privater Schlüssel, der für den Nutzer unzugänglich gespeichert wurde. Da als Betriebssystem für den Pi Linux verwendet wurde, ist das Ziel dieser Bachelorarbeit, das Verteilen von X.509-Zertifikaten auf Linux-basierten Endbenutzersystemen, damit erfüllt.

## Vergleich der EK- mit der DNS- und HTTP-Challenge
Um die Challenge-Typen vergleichen zu können, soll kurz wiederholt werden was die jeweiligen Challenges ausmacht, bevor sie auf Gemeinsamkeiten und Unterschiede geprüft werden.

Bei der HTTP- sowie der DNS-Challenge stellt der Server einen Token zur Verfügung, der die jeweiligen Challenges genau definiert. Diesen Token wandelt der Client, zusammen mit seinem Account Key, in einen Autorisierungsschlüssel um. Bei der DNS-Challenge wird zusätzlich noch mit dem SHA-256-Verfahren ein Hashwert gebildet. Anschließend werden die entsprechenden Werte base64-kodiert und als HTTP-Ressource beziehungsweise als "TXT Resource Record" zur Verfügung gestellt. Der Client sendet nun einen Request an den Server, um diesen wissen zu lassen, dass die Ressource nun für ihn zur Verfügung steht. Der Server fragt diese Information ab. Stimmt der Account Key mit dem vom Server generierten Wert überein, wurde die Challenge erfüllt.

Für die EK-Challenge muss zuerst der EK-Wert aus dem TPM-Chip gelesen und ein AK-Wert mithilfe des Chips generiert werden. Diese Werte bilden zusammen mit dem "ek"-Type den Identifier dieser Challenge und werden so dem Server übergeben. Dieser generiert nun aus beiden Werten ein Geheimnis, das der Client anfragen und lösen muss. Ist das geschafft, übersendet der Client das gelöste Geheimnis, base64-kodiert, zurück an den Server. Wurde das Geheimnis korrekt gelöst, gilt hier die Challenge als erfüllt.

Die wichtigste Gemeinsamkeit ist, dass in jeder der drei Challenge-Arten bewiesen werden muss, dass der Client die Kontrolle über den Wert im "identifier", egal ob EK, DNS oder Website, besitzt.
Dadurch, dass nur die Kontrolle validiert wird, ist die Integrität des Systems irrelevant für das ACME-Protokoll. Auch wenn es Möglichkeiten für die EK-Challenge gibt, die Systemintegrität zumindest teilweise zu überprüfen, was in  \ref{erweiterungen} besprochen wird, gibt es keinerlei Möglichkeiten für den Server sicherzustellen, dass sich nicht irgendeine dritte Partei die Kontrolle über Chip, Website oder DNS verschafft hat.

Einer der größten Unterschiede zwischen den alten Challenges und der neuen ist die Art der Überprüfung. Wo bei der DNS- und HTTP-Challenge der Server selbst aktiv werden muss, um den Autorisierungsschlüssel abzufragen, nimmt er in der EK-Challenge eine rein passive Rolle ein. Der Server muss seinerseits keinerlei Anfragen erstellen, was bei der HTTP-Challenge sogar zu Komplikationen führen kann. Werden beispielsweise mehrere Webserver verwendet, muss sichergestellt werden, dass auf allen der Autorisierungsschlüssel existiert [@challenge-types].
Einen weiteren Unterschied stellt die Art der Schlüsselgenerierung und -verwendung dar. Dadurch, dass der AK-Wert zusammen mit dem EK-Wert validiert wird, kann sichergestellt werden, dass beide Werte aus dem gleichen TPM-Chip stammen. Auch wenn eine neue Order aufgegeben wird, muss der Client diese Prüfung erneut antreten, um wiederholt zu bestätigen, dass EK- und AK-Wert aus dem gleichen Chip stammen. Aus diesem AK-Wert wird nun die CSR generiert, sodass der Server, sofern er den AK-Wert zusammen mit dem EK-Wert gespeichert hat, nur durch das Zertifikat genau identifizieren kann, welches Gerät gerade kommuniziert.

## Angriffsvektoren
In diesem Kapitel sollen allgemein mögliche sowie EK-Challenge-spezifische Angriffsvektoren besprochen werden, welche entweder durch die neue Challenge mit ihrer Infrastruktur dazugekommen sind oder aus dem generellen Aufbau des ACME-Protokolls entstehen.

Wie im letzten Kapitel bereits besprochen, prüft der ACME-Server nie die Integrität des anfragenden Systems. Schafft es ein Angreifer, die Kontrolle über den TPM-Chip zu erlangen, kann er sich über das ACME-Protokoll Zertifikate beschaffen. Kritische Informationen wie private Schlüssel aus dem Chip zu extrahieren, ist jedoch nicht möglich.

Der Server kann durch einen "Denial of Service (DoS)"-Angriff lahmgelegt werden. Hierbei wird der Server durch eine übermäßige Anzahl an Anfragen lahmgelegt. So können zwar keine Informationen extrahiert werden, das Ausstellen von Zertifikaten, aber auch die Verifikation bereits vorhandener Zertifikate kann dabei jedoch blockiert werden. Da der ACME-Server nicht nur als Website, sondern auch als CA funktioniert, kann, je nach Architektur des Servers, durch einen solchen Angriff großer Schaden angerichtet werden. Wenn ein neuer Kommunikationspartner auftritt, kann jedes Gerät zur Überprüfung des Zertifikats des Gesprächspartners eine Anfrage an die CA stellen, um sicherzustellen, dass das Zertifikat auch wirklich von ihr ausgestellt wurde. Können Zertifikate nicht mehr verifiziert werden, kann es passieren, dass Kommunikation grundsätzlich abgelehnt wird.
Hier gibt es verschiedene Möglichkeiten den Server zu schützen [@ddos-abwehr] [@ddos-anti] [@ddos-prvention].

Es gibt noch einige andere Angriffsmöglichkeiten, die nur kurz angesprochen aber nicht länger behandelt werden sollen, da sie unwahrscheinlich sind oder praktisch keinen Nutzen für den Angreifer bedeuten, auch wenn sie problematisch für den Client sein können. So kann clientseitig das Entfernen oder Zerstören des TPM-Chips die Kommunikation lahm legen, denn ohne Zertifikat ohne entsprechenden privaten Schlüssel ist Kommunikation unmöglich. In diesem Fall muss mindestens der Chip sowie der entsprechende Eintrag in der Serverdatenbank ausgetauscht werden.
Wenn ein Angreifer es schafft, sich die Kontrolle über den Server anzueignen, ist er in der Lage, jedwede Kommunikation zu erlauben, sodass effektiv keine Sicherheit mehr gewährleistet wird. Außerdem kann er die Datenbankeinträge löschen, was zu Problemen führen kann, wenn keine Backups gemacht wurden. Im schlimmsten Fall müsste jeder TPM-Chip ausgetauscht werden, da nicht mehr sichergestellt werden kann, ob es sich um den öffentlichen Schlüssels des EKs des TPMs handelt, der vor oder während des Angriffs in die Datenbank geschrieben wurde.

## Mögliche Erweiterungen \label{erweiterungen}
In diesem Kapitel sollen alle alternativen Umsetzungsmöglichkeiten sowie mögliche Erweiterungen besprochen werden. Dabei soll unterschieden werden zwischen clientseitigen Änderungen und serverseitigen Änderungen.

Wie bereits angesprochen, gibt es clientseitig, durch den TPM-Chip die Möglichkeit, die Integrität des Clients beim Boot-Vorgang zu überprüfen. Vereinfacht kann gesagt werden, dass zu Beginn des Boot-Vorgangs geprüft wird, ob das System so ist, wie es sein sollte. Dazu wird ein Startpunkt, ein sogenannter "Core Root of Trust for Measurement" erzeugt. Bei jedem Boot-Vorgang wird nun ein Wert erzeugt, der mit einem Hashverfahren in den Chip gespeichert wird. Weicht dabei ein Wert von den vorherigen ab, kann davon ausgegangen werden, dass das System nicht mehr in seinem originalen Zustand existiert [@tpm-architektur-integrity]. So kann zwar nicht verhindert werden, dass eine dritte Partei sich die Kontrolle über den Chip aneignet, sollte jedoch der Fehler gemacht werden und das Gerät zu irgendeinem Zeitpunkt ausgeschaltet werden, so kann dieses nicht wieder neu hochfahren.
Durch die aktuelle Implementierung des Clients kann dieser nicht auf mögliche Störungen des Servers reagieren. Eine sinnvolle Erweiterung könnte sein, Fehlerbehandlungen durchzuführen, falls dieser nicht erreicht werden kann oder Anfragen nicht richtig bearbeitet werden.

Serverseitig kann, sobald ein Client ein neues Konto anlegt, der öffentliche Teil seines Account Key in der Datenbank gespeichert werden. Übersendet nun dieser Client in einem New-Order-Request seinen EK- und AK-Wert, können alle drei Werte zusammen in der Datenbank verknüpft werden. Dadurch wird der Server im späteren Verlauf deutlich leichter handzuhaben. Wird beispielsweise eines der Geräte als vermisst gemeldet und sollen alle Zertifikate widerrufen werden, so kann der Server durch die Verknüpfung zwischen den Konto-Daten und dem EK nicht nur genau sagen, welches Client-Konto zu dem verlorenen Chip gehört und Auskunft darüber geben, was dieser in der letzten Zeit für Anfragen gestellt hat. Durch die logs ist es ihm auch möglich, sofort alle zugehörigen Zertifikate zu widerrufen, da diese durch die Verknüpfung mit der EK alle eindeutig diesem Client zugeordnet sind. Auch die Verwendung des EK-Zertifikates statt des in der Arbeit beschriebenen öffentlichen Schlüssels wäre möglich. So kann vor dem Eintragen des Wertes in der Datenbank das Zertifikat geprüft werden. Auch die Gültigkeit dieses Zertifikates kann immer wieder serverseitig überprüft werden, um sicherzustellen, dass der Hersteller nachträglich keine Fehler im Gerät entdeckt hat.

Wie bereits besprochen, wurde für die Umsetzung keine richtige Datenbank verwendet, sondern hartkodiert. Eine Möglichkeit, den Server sinnvoll zu erweitern, wäre das Hinzufügen einer solchen Datenbank mit entsprechender Infrastruktur, sowie das Bereitstellen einer API, die es autorisierten Personen erlaubt, Einträge in die Datenbank zu schreiben. Zugleich kann es auch sinnvoll sein, es Systemadministratoren zu erlauben, Zertifikate zu widerrufen, sollte beispielsweise ein Endbenutzer-System verloren gegangen sein.

Zusätzlich kann der Server auf einem "Docker-Container"[@docker] laufen gelassen werden. Abgesehen davon, dass der "Container" alle vom Server benötigten Ressourcen zur Verfügung stellt, kann so ein Serverstatus festgelegt werden, auf den immer wieder zurückgesetzt werden kann, falls es zu Komplikationen kommen sollte.

Eine Alternative zu dem im RFC8555 beschriebenen Vorgehen zum neuen Ausstellen von Zertifikaten ist das Verketten von Zertifikaten, auch "Certificate Chaining" genannt[@chain-of-trust]. Grob gesagt, wenn der Server dem bereits vorhanden Zertifikat vertraut, kann er, falls mit diesem Zertifikat ein neues angefragt wird, transitiv auch der neuen CSR vertrauen.
