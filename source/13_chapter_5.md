# Untersuchung von Angriffsvektoren

In diesem Kapietel sollen die Möglichen Angriffsvektoren besprochen werden die bei dem DNS sowie dem IP verfahren bestanden, sowie neue die durch die neue Methode erst hinzugekommen sind. Dabei wird unterteilt in Vektoren die in allen Verfahren relevant sind, jene die speziell auf das neue Verfahren zugeschnitten sind und abschließend sollen mögiche Einfallstore besprochen werden.

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





<!--
Kommentare können so hinzugefügt werden.

## Ergebnisse

Die Tabelle \ref{tabellenreferenz} zeigt uns wie man eine Tabelle hinzufügt. Integer tincidunt sed nisl eget pellentesque. Mauris eleifend, nisl non lobortis fringilla, sapien eros aliquet orci, vitae pretium massa neque eu turpis. Pellentesque tincidunt aliquet volutpat. Ut ornare dui id ex sodales laoreet.

<!-- Erzwingt eine neue Seite

\newpage

---------------------------------------------------------------------------
Spalte 1            Spalte 2                Spalte 3
--------------      -------------------     -------------------
Zeile 1               0.1                     0.2

Zeile 2               0.3                     0.3

Zeile 3               0.4                     0.4

Zeile 4               0.5                     0.6

---------------------------------------------------------------------------

Table: Das ist die Tabellenbeschriftung. Suspendisse blandit dolor sed tellus venenatis, venenatis fringilla turpis pretium. \label{tabellenreferenz}


## Auseinandersetzung

Das ist die Auseinandersetzung mit den Ergebnissen. Etiam sit amet mi eros. Donec vel nisi sed purus gravida fermentum at quis odio. Vestibulum quis nisl sit amet justo maximus molestie. Maecenas vitae arcu erat. Nulla facilisi. Nam pretium mauris eu enim porttitor, a mattis velit dictum. Nulla sit amet ligula non mauris volutpat fermentum quis vitae sapien.

## Schlussfolgerung

Das ist die Schlussfolgerung des Kapitels. Nullam porta tortor id vehicula interdum. Quisque pharetra, neque ut accumsan suscipit, orci orci commodo tortor, ac finibus est turpis eget justo. Cras sodales nibh nec mauris laoreet iaculis. Morbi volutpat orci felis, id condimentum nulla suscipit eu. Fusce in turpis quis ligula tempus scelerisque eget quis odio. Vestibulum et dolor id erat lobortis ullamcorper quis at sem.
-->
