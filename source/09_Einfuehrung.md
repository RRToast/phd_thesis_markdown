# Einführung

## Motivation
Nicht nur für die Kommunikation im Internet werden Zertifikate zur Prüfung der Authentizität der Kommunikationspartner verwendet. Zertifikate und Schlüssel stellen einen zentraler Bestandteil der Sicherheit in der Informatik dar und deren Verlust kann schwerwiegende Folgen haben. Beispielsweise können Geräte und Nutzer nicht mehr eindeutig identifiziert werden und jede Kommunikation zu und mit diesen wird unsicher. Das erlaubt es Angreifern sich als normalerweise vertrauenswürdige Kommunikationspartner zu tarnen um u.a. private Daten abfragen oder Industriespionage zu betreiben. Dabei wird unterschieden zwischen der Prüfung von Nutzern und Endgeräten. Eine Kommunikation kann von Anfang an abgelehnt werden, wenn sichergestellt werden kann, dass das anfragende Gerät nicht vertrauenswürdig ist. Aus diesem Grund muss eine Möglichkeit geschaffen werden Zertifikate sicher bereitzustellen und abzuspeichern, ohne das diese von einem Nutzer manipuliert werden könnten.

## Problemstellung
Es muss sichergestellt werden, dass das Zertifikat nicht missbraucht werden kann ohne dessen Nutzen einzuschränken. Wäre die Verwendung des Zertifikates zu kompliziert, ist das Verfahren nutzlos, da es unbrauchbar wird. Gleichzeitig muss ein Grad an Sicherheit vorherrschen, der es so schwer wie möglich macht das Zertifikat zu missbrauchen. Das gilt auch für den Initialen Prozess des anfragens des Zertifikates, sowie deren aktualisierung. Es muss ein Gleichgewicht zwischen Funktionalität, Sicherheit sowie Verwaltbarkeit geben. Das fängt vor dem ausstellen des Zertifikates an und hört erst auf, wenn das Zertifikat sicher verwahrt wurde.

## Verwandte Arbeiten
Diese Arbeit basiert auf dem ACME Protokoll, welches im RFC8555 definiert wurde, sowie einem Projekt von Google welches sich "go-attestation" nennt. In dieser Arbeit wird stark auf die Erweiterung des ACME Protokolls eingegangen, zwei Projekte die das auch getan haben, sind die Erweiterung des Verfahrens um IP Addresse, sowie das Verfahren zur Verwendung von TLS. Ich weiß nicht was ich hier sonst noch schreiben soll ...

<!--
- beschreiben des IP sowie des Telefon Protokolls
- beschreiben des Mircrosoft Protokolls
(TODO: microsoft projekt angeben) -->

## Übersicht über die Bachelorarbeit
Diese Bachelorarbeit ist in 4 Teile eingeteilt. Ein Grundlagenkapitel in dem die wichtigsten Begriffe die in dieser Arbeit vorkommen erklärt werden, sowie eine Einführung in das ACME Protokoll. Im Kapitel \ref{theoretisch} wird die Theoretische Umsetzung einer neuen Challenge für das ACME Protokoll besprochen. Hier wird auf die Verwendung verschiedener Schutzmaßnahmen von Gerät und Nutzer eingegangen. Im Anschließenden \ref{praktisch}ten Kapitel wird anhand von praktischen Beispielen erklärt, wie so ein Verfahren konkret umgesetzt werden kann. Abschließend wird die Arbeit genau analysiert und unter anderem auf Funktionalität sowie Schwachstellen überprüft. Hier wird auch ein kleiner Ausblick gegeben was anders hätte umgesetzt werden könnte und welche Vor und Nachteile das mit sich bringen würde. Abschließend wird in einem Fazit die Arbeit noch einmal zusammengefasst und mögliche nächste Schritte besprochen.
