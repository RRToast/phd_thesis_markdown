# Fazit

## Zusammenfassung

In dieser Arbeit wurde die Frage behandelt, wie eine sichere Verteilung von X.509-Zertifikaten auf Linux-basierten Endbenutzersystemen aussehen kann. Dabei wurde bei dieser Arbeit ein Schwerpunkt nicht nur auf die Verteilung von X.509-Zertifikaten, sondern auch auf deren Speicherung und Verwendung gelegt. Mit dieser Arbeit soll es möglich gemacht werden, die Funktionalität, die für Windows-Systeme bereits zur Verfügung steht, auch Linux-basierten Systemen zu ermöglichen.
Dabei wurde sich dafür entschieden, auf bereits existierende Projekte aufzubauen. Für das Erstellen und Verwalten von Zertifikaten sollte auf ACME zurückgegriffen werden und für die Prüfung von Endgeräten auf go-attestation von Google. Durch die Verbindung dieser Projekte und unter der Verwendung eines Chips, der eine eindeutige Identifikation erlaubt, war es möglich, für einen Pi, auf dem ein Linux-System lief, einen entsprechenden Client zu erstellen.
Um dieses Ziel der Forschungsfrage entsprechend umzusetzen, sind zwei Akteure vonnnöten. Der erste stellt das Linux-basierte Endbenutzersystem dar, das ein X.509-Zertifikat erhält. Das andere ist die Instanz, die ein solches Zertifikat zur Verfügung stellt. Sowohl ACME als auch go-attestation arbeiten dabei nach einem gleichen Client-Server-Modell, wodurch es möglich war, diese Projekte sinnvoll miteinander zu verknüpfen, um diese Bachelorarbeit zu verfassen. Der erste Schritt bestand dabei darin, die ACME-Kommunikation zu analysieren und um eine neue Challenge zu erweitern. Diese Challenge stellt einen Sicherungsmechanismus für die Verteilung der Zertifikate dar. Denn dadurch ist es serverseitig möglich, das Endbenutzersystem eindeutig zu identifizieren.
Ein ähnliches Verfahren wie das unter der Verwendung des TPM-Chips wurde für ACME bereits entwickelt. Dabei handelt es sich um zwei alternative Verfahren, die IP-Adressen oder Telefonnummern für die Identifikation des Endbenutzersystems verwenden. Auch wenn beide in der Lage sind, genau wie das in dieser Arbeit beschriebene Verfahren, Zertifikate auszustellen und das Endbenutzersystem zu identifizieren, gibt es gute Gründe, das neue Verfahren zu implementieren. Zum einen dient die Verwendung von Telefonnummern zur Prüfung weniger der Prüfung des Endbenutzersystems und mehr der des Nutzers des Systems. Zum anderen sind IP Adressen einem ständigen Wechsel ausgesetzt, was es dem Server schwierig macht, das genaue Endbenutzersystem zu definieren.
<!-- Regeln: Auführliche Schlussfolgerungen und Refelxion, zusammenfassung der zentralen Erkenntnisse, keine neuen Informationen, evtl Verweis auf offene Fragen/ evaluierung der Vorgehensweise, Präsens verweise auf meine Forschung im 1ter Vergangenheit


Zeck der Forschungsfrage

Umsetzung

Ergebnisse-->

## Future Work
Der nächste Schritt dieser Arbeit besteht darin, für das RFC8555 eine Erweiterung zu schreiben. Dieses Dokument würde, nach einigen Korrekturen und Überarbeitungen eine Erweiterung für das klassiche ACME-Protokoll darstellen, wie auch die IP und Telefonnummern Erweiterungen darstellen.

Ist diese Erweiterung ein fester Bestandteil des ACME-Protokolls, kann darauf aufgebaut werden. Eine beispielhafte Verwendung dieses Verfahrens könnte sein: Möchte eine größere Firma sicherstellen, dass alle Geräte, mit denen kommuniziert wird, über ein eigenes Zertifikat verfügen, so kann die Kommunikation auf der Prämisse aufbauen, dass sich, nachdem ein Zertifikat angefragt wurde, im TPM-Chip ein solches befindet. Diese Zertifikate können verwendet werden, damit alle Kommunikationspartner stets wissen, mit wem sie gerade Informationen austauschen. Der ACME-Server fungiert dann auch gleichzeitig als Anfragemöglichkeit für jeden Gesprächspartner, der das Zertifikat des jeweils anderen Gesprächspartners prüfen möchte.
Weiterführend wäre es auch sinnvoll, dieses Projekt statt in die abgeschwächte Version eines ACME-Servers (Pebble) in einen vollwertigen ACME-Server (zum Beispiel Boulder) zu implementieren.

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
