# Fazit

## Zusammenfassung

In dieser Arbeit wurde die Frage behandelt, wie eine sichere Verteilung von X.509-Zertifikaten auf Linux-basierten Endbenutzersystemen aussehen kann. Dabei wurde bei dieser Arbeit nicht nur ein Schwehrpunkt auf die Verteilung von X.509-Zertifikaten sondern auch auf deren Speicherung und Verwendung gelegt. Mit dieser Arbeit soll es möglich gemacht werden die Funktionalität welche für Windows Systeme bereits zur Verfügung steht auch Linux-basierte Systemen zu ermöglichen.
Dabei wurde sich dafür entschieden auf bereits existierende Projekte aufzubauen. Für das erstellen und verwalten von Zertifikaten sollte auf ACME zurückgegriffen werden und für die Prüfung von Endgeräten auf go-attestation von Google. Durch die Verbindung dieser Projekte und unter der Verwendung eines Chips, der eine eindeutige Identifikation erlaubt, war es möglich für einen Pi auf dem ein Linux System lief zu erstellen.
Um dieses Ziel, der Forschungsfrage entsprechend umzusetzen sind zwei Akteure von nöten. Der erste stellt das Linux-basierte Endbenutzersystem dar, welches ein X.509 Zertifikat erhält, das andere ist die Instanz, welche ein solches Zertifikat zur Verfügung stellt. Sowohl ACME als auch go-attestation arbeiten dabei nach einem gleichen Client Server Model und so war es möglich diese Projekte Sinvoll mit einander zu verknüpfen um diese Bachelorarbeit zu verfassen. Der erste Schritt bestand dabei darin, die ACME Kommunikation zu analysieren und um eine neue Challenge zu erweitern. Diese Challenge stellt einen sicherungsmechanismus für die Verteilung der Zertifikate da. Denn dadurch ist es Serverseitig möglich das Endbenutzersystem eindeutig zu identifizieren.

Zeck der Forschungsfrage

Umsetzung

Ergebnisse

Ein ähnliches Verfahren wie dass unter der Verwendung des TPM Chips wurde für ACME bereits entwickelt. Dabei handelt es sich um zwei alternative Verfahren welche IP Adressen oder Telefonnummern für die Identifikation des Endbenutzersystems verwenden. Auch wenn beide in der Lage sind, genau wie das in dieser Arbeit beschriebene Verfahren, Zertifikate auszugstellen sowie das Endbenutzersystem zu identifizieren, gab es gute Gründe das neue Verfahren zu implementieren. Einmal dient die Verwendung von Telefonnummern zur Prüfung weniger der Prüfung des Endbenutzersystems und mehr der des Nutzers des Systems. Zweitens sind IP Adressen einem ständigen Wechsel ausgesetzt, was es schwierig macht ....... <!-- warum schwierig? --> 


<!-- Regeln: Auführliche Schlussfolgerungen und Refelxion, zusammenfassung der zentralen Erkenntnisse, keine neuen Informationen, evtl Verweis auf offene Fragen/ evaluierung der Vorgehensweise, Präsens verweise auf meine Forschung im 1ter Vergangenheit -->

## Future Work

Auf diesem Projekt aufbauend kann nun eine


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
