# Evaluation

## Testlauf der ACME Erweiterung
Um die ACME Erweiterung zu testen habe ich auf meinem Rechner den ACME Server und auf einem Raspberry PI mit TPM Chip den Client laufen lassen. Ziel des Ablaufes war es sicherzustellen, dass die in 4. beschrieben client- und serverseitigen Erweiterung wie geplant funktionieren. Darunter gehören Funktionalitäten, wie das Anlegen eines Accounts und das Einholen eines Zertifikates, genauso wie die neue Challenge, die neue Art CSR zu erstellen, sowie der richtige Umgang mit dem TPM Chip und Zertifikaten.

![Get Request des Clients \label{mein_label}](source/figures/ACMEclientAblauf.png)
*ACME Ablauf auf Pi*

<!-- TODO: Was soll ich hier groß beschreiben?   Möglichkeiten: Zeit zum erstellen des Certifiates, Benutzerfreundlichkeit, Erweiterbarkeit, ... -->


## Ergebnisse

Der Output beschreibt den Ablauf des ACME Protokolls, erweitert um die "ek" Challenge. Am Ende dieser Kommunikation befindet sich im TPM Chip das Zertifikat, für einen Benutzer des Client geräts zugänglich gespeichert, sowie dessen privater Schlüssel, für den Nutzer unzugänglich gespeichert.

<!-- TODO: erweitern, in Verbindung mit dem Punkt drüber -->


## Vergleich der EK mit der DNS und HTTP Challenge
Um die Challenge-Typen vergleichen zu können soll kurz wiederholt werden was die jeweiligen Challenges ausmacht, bevor sie auf Gemeinsamkeiten und Unterschiede geprüft werden.

HTTP und DNS Challenge:
In beiden Challenges stellt der Server einen Token zur Verfügung, der die jeweiligen Challenges genau definiert. Diesen Token wandelt der Client, zusammen mit seinem Account Key, in einen Authorisierungsschlüssel um. Bei der DNS Challenge wird zusätzlich noch mit dem SHA-256 Verfahren ein Hashwert gebildet. Anschließend werden die entsprechenden Werte base64 codiert und als HTTP-Ressource beziehungsweise als TXT Resource Record zur Verfügung gestellt. Der Client sendet nun einen Request an den Server um diesen wissen zu lassen, dass die Ressource nun für ihn zur Verfügung steht. Der Server fragt diese Information ab. Stimmt der Account Key mit dem vom Server generierten Wert überein, wurde die Challenge erfüllt.

EK Challenge:
Für die EK Challenge muss zuerst der EK Wert aus dem TPM Chip gelesen und ein AK Wert mithilfe des Chips generiert werden. Diese Werte bilden zusammen mit dem "ek" Typ den Identifier dieser Challenge und werden so dem Server übergeben. Dieser generiert nun aus beiden Werten ein Geheimnis, welches der Client anfragen und lösen muss. Ist das geschafft, übersendet der Client das gelöste Geheimnis, base64-codiert, zurück an den Server. Wurde das Geheimnis korrekt gelöst gilt hier die Challenge als erfüllt.

Gemeinsamkeiten:
Auffällig ist, dass alle drei Challenge-Arten, nur Kontrolle über etwas beweisen: In jeder muss bewiesen werden, dass der Client die Kontrolle über den Wert im Identifier, egal ob EK, DNS oder Website, besitzt.
Dadurch dass nur die Kontrolle validiert wird, ist die *Integrität* des Systems irrelevant für das ACME Protokoll. Auch wenn es Möglichkeiten für die EK Challenge gibt, die Systemintegrität zumindest teilweise zu überprüfen, was in  \ref{erweiterungen} besprochen wird, gibt es keinerlei Möglichkeiten für den Server, sicherzustellen dass sich nicht irgendeine dritte Partei die Kontrolle über Chip, Website oder DNS verschafft hat.

Unterschiede:
Einer der größten Unterschiede zwischen den alten Challenges und der Neuen ist die Art der Überprüfung. Wo bei der DNS und HTTP Challenge der Server selbst aktiv werden muss, um den Authorisierungsschlüssel abfragen, so nimmt er in der EK Challenge eine rein passive Rolle ein. Der Server muss seinerseits keinerlei Anfragen erstellen, was bei der HTTP Challenge sogar zu Komplikationen führen kann. Werden beispielsweise mehrere Webserver verwendet, muss sichergestellt werden, das auf allen der Authorisierungsschlüssel existiert [@challenge-types].
Einen weiteren Unterschied stellt die Art der Schlüsselgenerierung und -Verwendung dar. Dadurch, dass der AK-Wert zusammen mit dem EK-Wert validiert wird, kann sichergestellt werden, dass beide Werte aus dem gleichen TPM Chip stammen. Auch wenn eine neue Order aufgegeben wird, muss der Client diese Prüfung erneut antreten um wiederholt zu bestätigen, dass EK- und AK-Wert aus dem gleichen Chip stammen. Aus diesem AK-Wert wird nun die CSR generiert, sodass der Server, insofern er den AK Wert zusammen mit dem EK Wert gespeichert hat, nur durch das Zertifikat genau identifizieren kann, welches Gerät gerade kommuniziert.


## Angriffsvektoren
In diesem Kapitel sollen allgemein mögliche, sowie EK-Challenge-spezifische Angriffsvektoren besprochen werden, welche entweder durch die neue Challenge mit all ihrer Infrastruktur dazu gekommen sind oder aus dem generellen Aufbau des ACME Protokolls entstehen.

Wie im letzten Kapitel bereits besprochen prüft der ACME Server nie die Integrität des anfragenden Systems. Schafft es ein Angreifer, die Kontrolle über den TPM Chip zu erlangen, kann er sich über ACME Zertifikate beschaffen, kritische Informationen wie private Schlüssel aus dem Chip zu extrahieren ist jedoch nicht möglich.

Ein serverseitiger Angriff kann ein *D*enial *o*f *S*ervice, kurz DoS Angriff sein. Hierbei wird der Server durch eine übermäßige Anzahl an Anfragen lahmgelegt. So können zwar keine Informationen extrahiert werden, das Ausstellen von Zertifikaten, aber auch die Verifikation bereits vorhandener Zertifikate kann dabei jedoch blockiert werden. Da der ACME Server nicht nur als Website sondern auch als CA funktioniert, kann, je nach Architektur des Servers, durch einen solchen Angriff großer Schaden angerichtet werden. Wenn ein neuer Kommunikationspartner auftritt kann jedes Gerät zur Überprüfung des Zertifikats des Gesprächspartners eine Anfrage an die CA stellen, um sicherzustellen dass das Zertifikat auch wirklich von ihr ausgestellt wurde. Können Zertifikate nicht mehr verifiziert werden, kann es passieren, dass Kommunikation grundsätzlich abgelehnt wird. <!-- TODO: Wenn Zeit, weiter Ausführen -->
-> Hier gibt es verschiedene Möglichkeiten den Server zu schützen [@ddos-abwehr] [@ddos-anti] [@ddos-prvention].

Es gibt noch einige andere Angriffsmöglichkeiten, die nur kurz angesprochen aber nicht länger behandelt werden sollen, da sie unwahrscheinlich sind oder praktisch keinen Nutzen für den Angreifer bedeuten, auch wenn sie problematisch für den Client sein können. So kann clientseitig das Entfernen oder Zerstören des TPM Chips die Kommunikation lahm legen, denn ohne Zertifikat ohne entsprechenden privaten Schlüssel ist Kommunikation unmöglich. In diesem Fall muss mindestens der Chip sowie der entsprechende Eintrag in der Serverdatenbank ausgetauscht werden.
Wenn ein Angreifer es schafft sich die Kontrolle über den Server anzueignen, ist er in der Lage jedwede Kommunikation zu erlauben und so effektiv keine Sicherheit mehr zu gewährleisten, außerdem kann er die Datenbank Einträge löschen, was wenn keine Backups gemacht werden, zu Problemen führen kann. Im schlimmsten Fall müsste jeder TPM Chip ausgetauscht werden, da nicht mehr sichergestellt werden kann ob es sich um einen Chip handelt der vor oder während dem Angriff in die Datenbank geschrieben wurde.

<!-- TODO: erweitern -->
<!-- Falls gebraucht, mehr Ideen unten im File -->

## Mögliche Erweiterungen \label{erweiterungen}
In diesem Kapitel sollen alle alternativen Umsetzungsmöglichkeiten, sowie mögliche Erweiterungen besprochen werden. Dabei soll unterschieden werden zwischen Clientseitigen Änderungen und Serverseitigen Änderungen.

Clientseitig:
Wie bereits angesprochen gibt es durch den TPM-Chip die Möglichkeit, die Integrität des Clients beim Bootvorgang zu überprüfen. Vereinfacht kann gesagt werden, dass zu Beginn des Bootvorgangs geprüft wird, ob das System so ist wie es sein sollte. Dazu wird ein Startpunkt, ein sogenannter *Core Root of Trust for Measurement* erzeugt. Bei jedem Bootvorgang wird nun ein Wert erzeugt, der mit einem Hashverfahren in den Chip gespeichert wird. Weicht dabei ein Wert von den vorherigen ab, kann davon ausgegangen werden, dass das System nicht mehr in seinem originalen Zustand existiert [@tpm-architektur-integrity]. So kann zwar nicht verhindert werden, dass eine dritte Partei sich die Kontrolle über den Chip aneignet, sollte jedoch der Fehler gemacht werden und das Gerät zu irgendeinem Zeitpunkt ausgeschaltet werden, so kann dieses nicht wieder neu hochfahren.

Durch die aktuelle Implementierung des Clients kann dieser nicht auf möglich Störungen des Servers reagieren. Eine sinnvolle Erweiterung könnte sein Fehlerbehandlungen durchzuführen, falls dieser nicht erreicht werden kann oder Anfragen nicht richtig bearbeitet werden.
<!-- TODO: Die aktuelle Implemntierung des Clients ist nicht für Serverseitige Störfälle ausgreichtet -->

Serverseitig:
Sobald ein Client einen neuen Account anlegt, kann sein accountgebundener öffentlicher Schlüssel in der Datenbank gespeichert werden. Übersendet nun dieser Client in einem new Order Request seinen EK und AK Wert können alle drei Werte zusammen in der Datenbank verknüpft werden. Dadurch wird der Server im späteren Verlauf deutlich leichter handzuhaben. Wird beispielsweise eines der Geräte als vermisst gemeldet und es sollen alle Zertifikate widerrufen werden, so kann der Server durch die Verknüpfung zwischen den Account-Daten und dem EK nicht nur genau sagen welcher Client-Account zu dem verlorenen Chip gehört und Auskunft darüber geben was dieser in der letzten Zeit für Anfragen gestellt hat. Durch die logs ist es ihm auch möglich, sofort alle zugehörigen Zertifikate zu widerrufen, da diese durch die Verknüpfung mit der EK alle eindeutig sind.

Wie bereits besprochen wurde für die Umsetzung keine richtige Datenbank verwendet. Eine Möglichkeit, den Server sinnvoll zu erweitern, wäre das Hinzufügen einer solchen Datenbank mit entsprechender Infrastruktur, sowie dem Bereitstellen einer API, die es autorisierten Personen erlaubt, Einträge in die Datenbank zu schreiben. Im gleichen Zug kann es auch sinnvoll sein, es Systemadministratoren zu erlauben, Zertifikate zu widerrufen, sollte beispielsweise ein Endbenutzer-System verloren gegangen sein.

Zusätzlich kann der Server auf einem Docker Container[@docker] laufen gelassen werden. Abgesehen davon, dass der Container alle vom Server benötigten Ressourcen zur Verfügung stellt, kann so ein Serverstatus festgelegt werden, auf den immer wieder zurückgesetzt werden kann, falls es zu Komplikationen kommen sollte.

Eine Alternative zu dem im RFC8555 beschrieben Vorgehen zum neuen Ausstellen von Zertifikaten ist das Verketten von Zertifikaten, auch Certificate Chaining genannt[@chain-of-trust]. Grob gesagt, wenn der Server dem bereits vorhanden Zertifikat vertraut, so kann er, falls mit diesem Zertifikat ein Neues angefragt wird, transitiv auch der neuen CSR vertrauen.

<!--  TODO: wenn was einfällt, erweitern :
- Richtige Datenbank erstellen, am besten mit einfacher API zum erweitern und Abfragen von Daten
- Weglassen der Prüfung welche Challenges gehen, wenn bei "ek" eh nur "ek-01" geht?
- Beim pollen des Stausees sollte es eine Fehlerbehandlung geben falls der Status negativ ist, sonst evtl endlos schleife ...
- Server kann CSR prüfen, ob der Public Key dem public AK Key entspricht
- Zertifikate Chaining um zu vermeiden dass der Client jedes mal den gleichen bums mit AK machen muss
-->


<!--
Bilder können mit der folgenden Syntax eingefügt werden:
![Bildunterschrift \label{mein_label}](source/figures/beispielbild.jpg){ width=50% }

Details zu den Attributen wie width und height gibt es unter:
http://pandoc.org/MANUAL.html#extension-link_attributes

![In den Medien werden für Hacker häufig Symbolbilder wie dieses verwendet. Foto: [pixabay.com](https://pixabay.com/photo-2883632/), Nutzer: [geralt](https://pixabay.com/de/users/geralt-9301/) Lizenz: [Creative Commons CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.de) \label{mein_label}](source/figures/beispielbild.jpg){ width=100% }

## Schlussfolgerung

Das ist die Schlussfolgerung des Kapitels. Quisque nec purus a quam consectetur volutpat. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. In lorem justo, convallis quis lacinia eget, laoreet eu metus. Fusce blandit tellus tellus. Curabitur nec cursus odio. Quisque tristique eros nulla, vitae finibus lorem aliquam quis. Interdum et malesuada fames ac ante ipsum primis in faucibus.

-->





<!--
## Was sind Angriffsvektoren

Einfallstore.

## Altbekannte Angriffsvektoren

1. Replay Angriffe (Replay noncen)
2. JWS (Man in the Middle Angriffe, da Signatur den Content schützt. Änderungen ohne die Singatur ungültig zu machen sind nicht möglich)
3. dos (Server abhänging. Nicht sicher ob Teil meiner BA)
4. Sozial Hacking (fällt flach da Automatisiert)

### Neuartige Angriffsvektoren

1. Impersonation Angriff
  Vor dem ersten Schritt: Er kann erfolgreich einen Account anlegen und eine Order senden, allerdings wird hier der Value überprüft und die Order verweigert
  Nach den ersten zwei Schritten: Die Account sowie die Order URL sind unbekannt. Anfragen können nicht geschickt werden.
  (Falls doch bekannt kann die Challenge nicht erfüllt werden, da den Private Key nur der Klient kennt)
  Nach dem Vallidieren: MÖGLICH? URL wird benötigt, sowie JWS Values, keine weitere Sicherheit

2. MitM
  Kommunikation verschlüsselt, JWS, Private Keys nur auf Client/Server. Allerdings, was ist wenn der Client als zwischen speicher funktioniert. Wenn er den JWS Wert lesen kann, ist er in der Lage die Kommunikation mit zu verfolgen -> Nutzen unklar

3. Continues Validation durch Zertifikate Chaining
  ?

4. Server Impersonation
  Möglich die gesammte Kommunikation zu faken -> Gerät wird nutzlos

5. Physischen Schaden bsp: TPM Chip entfernen, oder zerstört

6. Abschießen des Daemon (Zertifikate können nicht mehr ausgestellt werden)

7. Server DB kaputt machen (Daten verlust) / Datenbank mit falschen Daten füttern

8. Was passiert wenn ein Angreifer einen Stick einfügt und über diesen Bootet? / Was passiert wenn der TPM Chip abgebaut wird und wo anders eingesetzt wird?

-->
