# Einführung

## Motivation
Nicht nur für die Kommunikation im Internet werden Zertifikate zur Prüfung der Authentizität der Kommunikationspartner verwendet. Zertifikate und Schlüssel stellen einen zentraler Bestandteil der Sicherheit in der Informatik dar und deren Verlust kann schwerwiegende Folgen haben. Beispielsweise können Geräte und Nutzer nicht mehr eindeutig identifiziert werden und jede Kommunikation zu und mit diesen wird unsicher. Das erlaubt es Angreifern sich als normalerweise vertrauenswürdige Kommunikationspartner zu tarnen um u.a. private Daten abzufragen oder Industriespionage zu betreiben. Dabei wird unterschieden zwischen der Prüfung von Nutzern und Endgeräten. Eine Kommunikation kann von Anfang an abgelehnt werden, wenn sicher gestellt werden kann, dass das anfragende Gerät nicht vertrauenswürdig ist. Aus diesem Grund muss eine Möglichkeit geschaffen werden Zertifikate sicher bereitzustellen und abzuspeichern, ohne das diese von einem Nutzer manipuliert werden könnten.

## Problemstellung
Es muss sicher gestellt werden, dass das Zertifikat nicht missbraucht werden kann ohne dessen Nutzen einzuschränken. Wäre die Verwendung des Zertifikates zu kompliziert, ist das Verfahren nutzlos, da es unbrauchbar wird. Gleichzeitig muss ein Grad an Sicherheit vorherschen der es so schwer wie möglich macht das Zertifkat zu missbrauchen. Das gilt auch für den Initialen Prozess des anfragens des Zertifikates, so wie dessen aktualisierung. Es muss also ein Gleichgewicht zwischen Funktionalität, Sicherheit sowie Verwaltbarkeit geben.

## Verwandte Arbeiten
Diese Arbeit basiert auf dem ACME Protokoll, welches im RFC8555 definiert wurde, sowie einem Projekt von Google welches sich "go-attestation" nennt. Vergleichbare Arbeit
- beschreiben des IP sowie des Telefon Protokolls
- beschreiben des Mircrosoft Protokolls
(TODO: microsoft projekt angeben)

## Übersicht über die Bachelorarbeit
Diese Bachelorarbeit ist in 4 Teile eingeteilt. Ein Grundlagenkapitel in dem die wichtigsten Begriffe die in dieser Arbeit vorkommen erklärt werden, sowie eine Einführung in das ACME Protokoll. I Kapitel \ref{theoretisch} wird die Theoretische Umsetzung einer neuen Challenge für das ACME Protokoll besprochen und im Anschließenden \ref{praktisch}ten Kapitel wird behandelt wie so ein Verfahren konkret umgesetzt werden kann. Abschließend wird die Arbeit genau analysiert und unter anderem auf Funktionalität sowie Schwachstellen überprüft.

<!-- TODO: alles überprüfen und erweitern -->
