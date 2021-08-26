# Abstract {.unnumbered}



In dieser Arbeit wird die Fragestellung behandelt, wie es möglich ist für Linx-basierten Endbenutzersysteme Zertifikate zu verteilen. Zu diesem Zweck wurde mithilfe des TPM Moduls eine neue ACME Challenge entwickelt. Mit der neuen sogennten "EK" Challenge ist es dem Endbenutzersystem möglich sich gegenüber eines ACME Servers zu verifizieren. Um das Verfahren umzusetzen wurde, statt einen neuen ACME Server zu schrieben auf ein Projekt von letsencrypt das sich pebble nennt zurückgegriffen. Dabei handelt es sich um einen light-weight Server welcher in dieser Arbeit so umgebaut wurde, dass es einem ebenfalls in dieser Arbeit geschrieben Client möglich ist die neue Challenge zu verwenden. Das Verfahren funktioniert und kann verwendet werden um das ACME Protokoll zu erweitern. Im Rahmen dieser Arbeit werden auch weiterführende Sicherheitsmaßnahmen besprochen, welcher man sich bei der Umsetzung dieses Projektes bedienen kann.

<!--
(Worum geht es?)
(Wie bin ich vorgegangen?)
(Was sind meine wichtigsten Ergebnisse?)
(Was bedeuten meine Ergebnisse?)
-->

\pagenumbering{arabic}
\setcounter{page}{1}

\newpage
