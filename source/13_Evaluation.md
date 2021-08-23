# Evaluation

## Testlauf der ACME Erweiterung
Um die ACME Erweiterung zu testen habe ich auf meinem Rechner den ACME Server und auf einem Raspberrypi mit TPM Chip den Client laufen lassen. Ziel des Ablaufes war es sicherzustellen, dass die in 3. beschrieben Client und Serverseitigen Erweiterung wie geplant funktionieren. Darunter gehören vorher bereits bekannte Funktionalitäten, wie ein Account Anlegen und eine Certifikat einzuholen. Genauso wie die neue Challenge, die neue Art CSR zu erstellen, sowie der richtige Umgang mit dem TPM Chip.

![Get Request des Clients \label{mein_label}](source/figures/ACMEclientAblauf.png)
*ACME Ablauf auf Pi*

Der Output beschreibt den Ablauf des ACME Protokolls, erweitert um die "ek" Challenge. Am ende dieser Kommunikation befindet sich im TPM Chip das Zertifikat, für einen Nutzer des Client gerätes zugänglich gespeichert, sowie dessen privater Schlüssel, für den Nutzer unzugänglich gespeichert.

<!-- TODO: Was soll ich hier groß beschreiben?   Möglichkeiten: Zeit zum erstellen des Certifiates, Benutzerfreundlichkeit, Erweiterbarkeit, ... -->


## Ergebnisse

Das sind die Ergebnisse. In vitae odio at libero elementum fermentum vel iaculis enim. Nullam finibus sapien in congue condimentum. Curabitur et ligula et ipsum mollis fringilla.

<!-- TODO: erweitern, in Verbindung mit dem Punkt drüber -->


## Vergleich der EK mit der DNS und HTTP Challenge
Um die Challenge Typen vergleichen zu können soll kurz wiederholt werden was die jeweiligen Challenges ausmacht, bevor sie auf Gemeinsamkeiten und Unterschiede geprüft werden.

HTTP und DNS Challenge:
In beiden Challenges stellt der Server einen Token zur Verfügung, der die jeweilige Challenges genau definiert. Diesen Token wandelt der Client, zusammen mit seinem Account Key, in einen Authorisierungsschlüssel um. Bei der DNS Challenge wird zusätzlich noch mit dem SHA-256 Verfahren der Hashwert gebildet. Anschließend werden die entsprechenden Werte base64 codiert und als HTTP Resource beziehungsweise als DNS Eintrag zur Verfügung gestellt. Der Client sendet nun einen Request an den Server um diesen Wissen zu lassen, dass die Resource nun für ihn zur Verfügung steht. Der Server frägt diese Information ab. Stimmt der Account Key mit dem vom Server generierten Wert über ein, wurde die Challenge erfolgreich erfüllt.

EK Challenge:
Für die EK Challenge muss zuerst der EK Wert aus dem TPM Chip gelesen und ein AK Wert mithilfe des Chips generiert werden. Diese Werte bilden zusammen mit dem "ek" Typ den Identifier dieser Challenge und werden so dem Server übergeben. Dieser generiert nun aus diesen beiden Werten ein Geheimniss, welches der Client anfragen und lösen muss. Ist das geschafft übersendet der Client das gelöste Geheimniss base64 codiert, zurück an den Server. Wurde das Geheimniss korrekt gelöst gilt hier die Challenge als erfüllt.

Gemeinsamkeiten:
Auffällig ist, dass alle drei Challenge Arten, Kontrolle über etwas beweisen. In jedem muss beweisen werden, dass der Client die Kontrolle über den Wert im Identifier, egal ob EK, DNS oder Website beweisen.
Dadurch das nur die Kontrolle validiert wird, ist die Integrität des Systems irrelevant für das ACME Protokoll. Auch wenn es Möglichkeiten gibt, wie für die EK Challenge gibt, die System Integrität zumindest Teilweise überprüft werden kann, was im  \ref{erweiterungen} besprochen werden sollen, gibt es keinerlei Möglichkeiten für den Server sicher zu stellen, dass sich nicht irgendeine dritte Partei die Kontrolle über Chip, Website oder DNS verschafft hat. Das ist eine Tatsache die im Umgang mit ACME nicht vergessen werden sollte.

Unterschiede:
Einer der größten Unterschiede zwischen den alten Challenges und der neuen ist die Art der Überprüfung. Wo bei der DNS und HTTP CHallenge der Server selbst aktiv werden muss um den Authorisierungsschlüssel abzufragen, so nimmt er in der EK Challenge eine rein passive Rolle ein. Der Server muss seinerseits keinerlei Anfragen erstellen was bei der HTTP Challenge sogar zu komplikationen führen kann. Wenn beispielsweise mehrere Webserver verwendet werden, muss sicher gestellt werden das auf allen der Authorisierungsschlüssel existiert [@challenge-types].
Ein weiteren Unterschied stellt die Art der Schlüssel generierung und Verwendung dar. Dadurch, dass der AK Wert zusammen mit dem EK Wert validiert wird, kann sichergestellt werden, dass beide Werte aus dem gleichen TPM Chip stammen. Auch wenn eine neue Order aufgegeben wird, muss der Client diese Prüfung erneut antreten um wiederholt zu bestätigen, dass EK und AK Wert aus dem gleichen Chip stammen. Aus diesem AK Wert wird nun die CSR generiert sodass der Server, insovern er den AK Wert zusammen mit dem EK Wert gespeichert hat, nur durch das Zertifikat genau identifizieren welches Gerät gerade kommuniziert.


## Angriffsvektoren
In diesem Kapitel sollen allgemein mögliche, sowie EK-Challenge spezifische mögliche Angriffsvektoren besprochen werden, welche die neue Challenge mit all ihrer Infrastruktur mit sich gebracht hat. Wenn mögliche Gegenmaßnahmen bekannt sind werden sie jeweils dazu geschrieben.

Wie im letzen Kapitel bereits besprochen Prüft der ACME Server nie die Integrität des entsprechenden Systems. Schafft es ein Angreifer sich die Kontrolle über den TPM Chip zu erlangen, kann er sich über ACME Zertifikate beschaffen.
-> Zwar kann sich der Angreifer enventuell auf den Chip zugreifen, kritische Informationen wie Private Schlüssel aus dem Chip zu extrahieren ist jedoch nicht möglich.

Ein Serverseitiger Angriff kann ein *D*enial *o*f *S*ervice kurz DoS Angriff sein. Hierbei wird der Server lahmgelegt durch eine übermäßige Anzahl an Anfragen. So können zwar keine Informationen extrahiert werden, das austellen von Zertifikaten aber auch die Verifikation bereits vorhandener Zertifikate kann dabei jedoch lahmgelegt werden. Da der ACME Server nicht nur als Website sondern auch als CA fungiert, kann je nach Architektur des Servers, durch einen solchen Angriff kann großer Schaden angerichtet werden. Können Zertifikate nicht mehr verifiziert werden kann es passieren, dass Kommunikation grundsätzlich abgelehnt wird. <!-- TODO: Wenn Zeit, weiter Ausführen -->
-> Hier gibt verschiedene Möglichkeiten den Server zu schützen [@ddos-abwehr] [@ddos-anti] [@ddos-prvention].

Es gibt noch einige andere Angriffsmöglichkeiten, die nur kurz angesprochen aber nicht länger behandelt werden sollen, da sie unwahrscheinlich oder praktisch keinen Nutzen für den Angreifer bedeuten, auch wenn sie problematisch für den Client sein können. So kann Clientseitig das entfernen oder zerstören des TPM Chips die Kommunikation lahm legen. Ohne Chip kein privaten Schlüssel, ohne privaten Schlüssel keine verschlüsselte Kommunikation. In diesem Fall muss mindestens der Chip ausgetauscht werden.
Wenn ein Angreifer es schafft sich die Kontrolle über den Server anzueignen ist er in der lage jedwede Kommunikation zu erlauben und so effektiv keine Sicherheit mehr zu gewährleisten, außerdem kann er die Datenbank Einträge löschen, was wenn keine Backups gemacht werden, zu Problemen führen kann. Im schlimmsten Fall müsste jeder TPM Chip ausgetauscht werden, da nicht mehr sichergestellt werden kann ob es sich um einen Chip handelt der vor oder während dem Angriff in die Datenbank geschrieben wurde.

<!-- TODO: erweitern -->
<!-- Falls gebraucht, mehr Ideen unten im File -->

## Mögliche Erweiterungen \label{erweiterungen}
In diesem Kapitel sollen alle Ideen besprochen werden die optional sind, oder thematisch nicht gepasst haben. Dabei soll unterschieden werden zwischen Client seitigen Änderungen und Serverseitigen Änderungen.

Clientseitig:
Wie bereits angesprochen gibt es durch den TPM Chip die Möglichkeit die Integrität des Clients beim bootvorgang zu überprüfen. Vereinfacht kann gesagt werden, dass zu beginn des boot vorgangs geprüft wird ob das System so ist wie es sein sollte. Dazu wird ein startpunkt, ein sogenannter Core Root of Trust for Measurement erzeugt. Bei jedem Boot Vorgang wird nun ein Wert erzugt, der mit einem Hash verfahren in den Chip gespeichert wird. Weicht dabei ein Wert von den vorherigen ab, kann davon ausgegangen werden, dass das System nicht mehr in seinem Originalen Zustand existiert [@tpm-architektur-integrity].

Serverseitig:
Sobald ein Client einen neuen Account anlegt, kann sein Account gebundener öffentlicher Schlüssel, in der Datenbank gespeichert werden. Übersendet nun dieser Client in einem newOrder Request seinen EK und AK Wert können alle drei Werte zusammen in der Datenbank verknüpft werden. Dadurch wird der Server im späteren Verlauf deutlich leichter handzuhaben. Wird beispielsweise eines der Geräte als vermisst gemeldet und es sollen alle Zertifikate revoked werden, so kann der Server durch die Verknüpfung zwischen den Account Daten und dem EK nicht nur genau sagen welcher Client Account zu dem verlorenen Chip gehört und Auskunft darüber geben was dieser in der letzten Zeit für Anfragen gestellt hat durch die logs. Es ist ihm auch möglich sofort alle zugehörigen Zertifikate zu revoken, da diese durch die Verknüpfung mit der EK alle eindeutig sind.

<!--  TODO: wenn was einfällt, erweitern :
- Richtige Datenbank erstellen, am besten mit einfacher API zum erweitern und Abfragen von Daten
- Weglassen der Prüfung welche Challenges gehen, wenn bei "ek" eh nur "ek-01" geht?
- Beim pollen des Statusees sollte es eine Fehlerbehandlung geben falls der Status negativ ist, sonst evtl endlos schleife ...
- Server kann CSR prüfen, ob der Public Key dem public AK Key entspricht
- Zertifikate Chaining um zu vermeiden dass der Client jedes mal den gelichen bums mit AK machen muss

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
