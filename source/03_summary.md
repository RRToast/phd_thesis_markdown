# Abstract {.unnumbered}



In dieser Arbeit wird die Fragestellung behandelt, wie es möglich ist, für Linux-basierte Endbenutzersysteme Zertifikate zu verteilen. Zu diesem Zweck wurde mithilfe des "Trusted Platform Module" eine neue Challenge für die "Automated Certificate Management Environment" (ACME) entwickelt. Mit der neuen, für diese Arbeit entwickelten, "EK"-Challenge ist es dem Endbenutzersystem möglich, sich gegenüber eines ACME-Servers zu verifizieren. Um das Verfahren umzusetzen, wurde, statt einen neuen ACME-Server zu schreiben, auf ein Projekt von "letsencrypt", das sich "pebble" nennt, zurückgegriffen. Dabei handelt es sich um eine vereinfachte Version eines Servers, der in dieser Arbeit so umgebaut wurde, dass es einem ebenfalls in dieser Arbeit geschriebenen Client möglich ist, die neue Challenge zu verwenden. Das Verfahren wurde in dieser Arbeit getestet, funktioniert und kann verwendet werden, um das ACME-Protokoll zu erweitern. Im Rahmen dieser Arbeit werden auch weiterführende Sicherheitsmaßnahmen besprochen, welcher man sich bei der Umsetzung dieses Projektes bedienen kann.

<!--
(Worum geht es?)
(Wie bin ich vorgegangen?)
(Was sind meine wichtigsten Ergebnisse?)
(Was bedeuten meine Ergebnisse?)
-->

\pagenumbering{arabic}
\setcounter{page}{1}

\newpage
