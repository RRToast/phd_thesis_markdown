# Evaluation

## Testlauf der ACME Erweiterung
Um die ACME Erweiterung zu testen habe ich auf meinem Rechner den ACME Server und auf einem Raspberrypi mit TPM Chip den Client laufen lassen. Ziel des Ablaufes ist es erst einen Account zu erstellen, dann eine Order mit neuem Identifier abzusenden, die neue Challenge zu verwenden und am Ende ein Zertifikat zu erhalten.

![Get Request des Clients \label{mein_label}](source/figures/ACMEclientAblauf.png)
*ACME Ablauf auf Pi*

Der Output beschreibt den Ablauf des ACME Protokolls, erweitert um die "ek" Challenge. Am ende dieser Kommunikation befindet sich im TPM Chip das Zertifikat, für einen Nutzer des Client gerätes zugänglich gespeichert, sowie dessen privater Schlüssel, für den Nutzer unzugänglich gespeichert.

<!-- TODO: Was soll ich hier groß beschreiben?   Möglichkeiten: Zeit zum erstellen des Certifiates, Benutzerfreundlichkeit, Erweiterbarkeit, ... -->

## Vergleich der EK mit der DNS und HTTP Challenge
Vorteile und Nachteile von DNS, HTTP und EK.

HTTP und DNS Challenge:
In beiden Challenges stellt der Server einen Token zur Verfügung, der die jeweilige Challenges genau definiert. Dabei wandelt der Client diesen Token, zusammen mit seinem Account Key. Bei der DNS Challenge wird zusätzlich noch mit dem SHA-256 Verfahren der Hashwert gebildet. Anschließend werden beide Werte base64 codiert als HTTP Resource beziehungsweise als DNS eintrag zur Verfügung gestellt. Der Client sendet nun einen Request an den Server um diesen Wissen zu lassen, dass die Resource nun für ihn zur Verfügung steht. Der Server frägt diese Information nun ab, stimmt der Account Key mit dem vom Server generierten Wert über ein wurde die Challenge erfolgreich erfüllt.

EK Challenge:
Für die EK Challenge muss zuerst der EK Wert aus dem TPM Chip gelesen und ein AK Wert mithilfe des Chips generiert werden. Diese Werte bilden zusammen mit dem "ek" Typ den Identifier dieser Challenge und werden so dem Server übergeben. Dieser generiert nun aus diesen beiden Werten ein Geheimniss, welches der Client anfragen und lösen muss. Ist das geschafft übersendet der Client das gelöste Geheimniss base64 codiert, zurück an den Server.

Gemeinsamkeiten:
Auffällig ist, dass alle drei Challenge Arten Kontrolle über etwas beweisen. In jedem muss beweisen werden, dass der der Client die Kontrolle über den Wert im Identifier, egal ob EK, DNS oder Website nicht, besitzt.

Unterschiede:
Einer der größten Unterschiede zwischen den alten Challenges und der neuen ist die Art der Überprüfung. Wo bei der DNS und HTTP CHallenge der Server selbst aktiv werden muss um den Account Key abzufragen, so nimmt er in der EK Challenge eine rein passive Rolle ein. Der Server muss seinerseits keinerlei Anfragen erstellen was zu komplikationen führen könnte, wenn beispielsweise mehrere Websiten mit gleichem Namen existieren oder der DNS Anbiter keine API zur Verfügung stellt [@challenge-types].
Ein weiteren Unterschied stellt die Art der Schlüssel generierung und Verwendung dar. Dadurch, dass der AK Wert zusammen mit dem EK Wert validiert wird, kann sichergestellt werden, dass beide Werte aus dem gleichen TPM Chip stammen. Auch wenn eine neue Order aufgegeben wird, muss der Client diese Prüfung erneut antreten um wiederholt zu bestätigen, dass EK und AK Wert aus dem gleichen Chip stammen.


## Angriffsvektoren
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
### Mögliche Angriffe

### Schutzmechanismen

## Mögliche Erweiterungen



## Ergebnisse

Das sind die Ergebnisse. In vitae odio at libero elementum fermentum vel iaculis enim. Nullam finibus sapien in congue condimentum. Curabitur et ligula et ipsum mollis fringilla.

## Auseinandersetzung

Abbildung \ref{mein_label} zeigt wie man eine Abbildung einfügen kann. Donec ut lacinia nibh. Nam tincidunt augue et tristique cursus. Vestibulum sagittis odio nisl, a malesuada turpis blandit quis. Cras ultrices metus tempor laoreet sodales. Nam molestie ipsum ac imperdiet laoreet. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

<!--
Bilder können mit der folgenden Syntax eingefügt werden:
![Bildunterschrift \label{mein_label}](source/figures/beispielbild.jpg){ width=50% }

Details zu den Attributen wie width und height gibt es unter:
http://pandoc.org/MANUAL.html#extension-link_attributes

![In den Medien werden für Hacker häufig Symbolbilder wie dieses verwendet. Foto: [pixabay.com](https://pixabay.com/photo-2883632/), Nutzer: [geralt](https://pixabay.com/de/users/geralt-9301/) Lizenz: [Creative Commons CC0](https://creativecommons.org/publicdomain/zero/1.0/deed.de) \label{mein_label}](source/figures/beispielbild.jpg){ width=100% }

## Schlussfolgerung

Das ist die Schlussfolgerung des Kapitels. Quisque nec purus a quam consectetur volutpat. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. In lorem justo, convallis quis lacinia eget, laoreet eu metus. Fusce blandit tellus tellus. Curabitur nec cursus odio. Quisque tristique eros nulla, vitae finibus lorem aliquam quis. Interdum et malesuada fames ac ante ipsum primis in faucibus.

-->
