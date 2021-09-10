# Grundlagen
Die Bachelorarbeit baut auf dem TPM sowie dem ACME-Protokoll auf. In diesem Abschnitt der Arbeit sollen diese beiden Themenbereiche so erklärt werden, dass in den folgenden Kapiteln klar wird, auf welchem Fundament die Arbeit aufgebaut ist. Denn sie stellen die Grundlage für die Identifizierung der Endbenutzersysteme sowie die sichere Erstellung, Verteilung und Verwaltung von X.509-Zertifikaten dar. Zuerst werden grundlegende Funktionalitäten des TPM besprochen, bevor der Ablauf sowie die wichtigsten Konzepte des ACME-Protokolls dargestellt werden.

## Trusted Platform Module
Bei dem \textbf{TPM} handelt es sich um ein Modul, mit dem Funktionen der Sicherheit auf einer physischen Ebene umgesetzt werden sollen. Obwohl dieses Modul erst 2009 von der "International Organization for Standardization" (ISO) und der "International Electrotechnical Commission" (IEC) [@tpm_iso2009] beschrieben wurde, existierten 2011 bereits 300 Millionen dieser Chips [@a_formal_analysis_of_authentication_in_the_tpm], eine Zahl, die mit der Ankündigung von Windows, für ihr neues Betriebssystem Windows 11 TPM2.0-Chips als Anforderung zu stellen, wahrscheinlich weiter steigen wird[@heise_tpm_windows]. Die Idee des TPM ist es, die Limitationen und Probleme, die Sicherheitssoftware und standardmäßige Hardware mit sich bringen, zu beheben. Dazu gehört ungeschützter und volatiler Speicher sowie unsichere kryptographische Hardware.
Der Aufbau des TPM ist recht komplex und wird in dem offiziellen Dokument der "Trusted Computing Group" auf etwa 300 Seiten zusammengefasst[@tpm-architektur]. Da das Modul ein eigenes "Application Programming Interface" (API) zur Verfügung stellt, ist es möglich, mit diesem zu kommunizieren. Gleichzeitig besitzt das Modul zwei für diese Arbeit sehr relevante Komponenten. Zum einen einen geschützten persistenen Speicher, der es erlaubt, wichtige Informationen sicher abzuspeichern[@a_formal_analysis_of_authentication_in_the_tpm]. Zum anderen eine kryptographische Einheit, die Schlüsselpaare erstellen kann [@tpm-aufbau]. Dabei wird sichergestellt, dass die kryptographischen Verfahren auf Hardware ausgeführt werden, die dafür gemacht ist, sichere Ergebnisse zu liefern. Für Schlüsselpaare, die mithilfe der kryptographischen Einheit erstellt werden, kann sichergestellt werden, dass der private Teil des Schlüssels nach der Erstellung auf dem TPM direkt in dem gesicherten persistenten Speicher abgelegt wird und das Modul zu keiner Zeit verlässt. Diese Tatsache kann verwendet werden, um das Gerät, welches den TPM-Chip verwendet, an diesem zu identifizieren. Jeder Chip verfügt über einen sogenannten "Endorsement Key" (EK). Dabei handelt es sich in der Regel um drei Teile: einen privaten Schlüssel im gesicherten Speicher, auf den nicht zugegriffen werden kann, einen öffentlichen Schlüssel, auf den zugegriffen werden kann, sowie ein dazugehöriges Zertifikat, das vom Hersteller signiert wurde[@a_practical_guide_to_tpm]. An diesem Zertifikat in Verbindung mit dem entsprechenden privaten Schlüssel kann der TPM-Chip eindeutig identifiziert werden.

## Automatic Certificate Management Enviroment
Die \textbf{ACME} besteht aus zwei Teilen: erstens einer Instanz, die Zertifikate verwalten kann, einer sogenannten "Certificate Authority" (CA), die Zertifikate erstellen und widerrufen kann, und zweitens einer automatisierten Schnittstelle, die erst prüft, ob Anfragen valide sind, und diese dann an die CA weiter gibt. Dadurch können Zertifikate automatisch angefragt werden. Dazu wird auf dem Gerät, das ein Zertifikat benötigt, ein ACME-Client ausgeführt, der eine Anfrage an den entsprechenden ACME-Server stellt. Dieser prüft dann mit Herausforderungen (Challenges), ob der Client tatsächlich der ist, für den er sich ausgibt. Ist der Client in der Lage, die Challenge zu erfüllen, kann er ein Zertifikat anfragen. Dieses Prinzip soll sich für diese Bachelorarbeit zunutze gemacht werden. Auch hier soll mit einem automatisierten Verfahren erst der Client geprüft und anschließend ein Zertifikat ausgestellt werden.
Der ACME-Server kann dabei nur mit integrierter Datenbank verwendet werden, da jeder Client, der ein Zertifikat anfragen möchte, zuerst ein Konto erstellen muss, das in der Datenbank gespeichert wird. Für dieses Konto kann der Client dann Anfragen nach Zertifikaten schicken, muss dabei jedoch für jede Anfrage eine Challenge erfüllen. Die Art der Challenge, ob nun DNS oder HTTP – beide werden im Verlauf der Arbeit noch genauer behandelt – kann der Client dabei frei wählen. Die folgenden Erklärungen beziehen sich auf ACME, wie es im RFC8555 definiert ist [@rfc-8555].

### Hintergrund
Ein ACME-Server, der nicht gleichzeitig als Webserver dient, muss laut RFC8555 mindestens eine Schnittstelle zur Verfügung stellen, die unverschlüsselt erreicht werden kann. Diese dient als Übersicht (Directory) über alle URLs die benötigt werden, damit der Client mit dem Server kommunizieren kann. Darunter finden sich zum Beispiel URLs, um ein Zertifikat zu widerrufen, eine Replay-Nonce zu erhalten und ein Konto zu erstellen. Eine Replay-Nonce ist eine zufällig generierte Zahl, die jede Nachricht eindeutig kennzeichnet und so vor Replay-Angriffen schützt. Jede Kommunikation, mit Ausnahme des GET-Requests zum Erhalten des Directory sowie dem Erhalten der Replay-Nonce, ist verschlüsselt und muss mit einer Replay-Nonce abgesichert werden. Dabei übersendet der Server bei jeder Anfrage des Clients auch eine Replay-Nonce im Header der Antwort mit, sodass diese nicht jedes Mal neu angefragt werden muss. Jede Kommunikation, ausgenommen die genannten zwei, muss als POST oder POST-as-GET-Request durchgeführt werden. POST-as-GET bedeutet, dass jede Anfrage, die normalerweise ein GET-Request wäre, nun als POST-Request mit leerem, aber signiertem Body, geschickt wird. POST-as-GET-Requests sind unabdingbar, da jede Kommunikation durch "JSON Web Signature" (JWS) gesichert werden muss und der Body des GET-Requests keine definierte Form hat[@rfc-7231]. Die Schlüsselpaare, die für die Kommunikation mit JWS notwendig sind, müssen vorher clientseitig erstellt werden.

### Ablauf
Im Folgenden soll der Ablauf einer ACME-Kommunikation von der ersten Nachricht bis zum Erhalt des Zertifikates dargestellt werden. Der Ablauf des ACME-Protokolls ändert sich abhängig davon, ob der Client bereits über ein Konto auf dem Server verfügt. Hier soll ein Ablauf beschrieben werden, in dem der Client noch keinerlei Kontakt mit dem Server hatte, also kein Konto besitzt. Der Einfachheit halber wird die Kommunikation aus Sicht des Clients dargestellt und die internen Abläufe des ACME-Servers außer Acht gelassen, da sie von Server zu Server unterschiedlich sein können.
Zuallererst muss der Client eine Anfrage an das Directory stellen, um zu erfahren, welche URL für welche Kommunikation benötigt wird. Sind die URLs bereits bekannt, kann dieser vorbereitende Schritt übersprungen werden.

#### Nonce
"Replay"-Noncen werden im ACME-Protokoll verwendet um vor "replay"-Angriffen zu schützen. Dabei muss jede Kommunikation vom Client zum Server durch eine solche Nonce geschützt sein, nur zwei im Kapitel 2.2.1 besprochene Anfragen sind von dieser Regel ausgenommen. Im weiteren Ablauf des Protokolls wird die Nonce in jeder Antwort des Servers mitgeschickt, damit der Client nicht wieder eine neue Anfrage nur für die "Replay"-Nonce senden muss. Dadurch entsteht eine Kette, die aus der Anfrage des Clients mit erhaltener Nonce und Antwort des Servers mit neuer Nonce besteht. Wenn die Nonce jedoch abgelaufen ist, da die letzte Kommunikation länger zurückliegt, oder der Client noch gar keine Anfrage gestellt hat und somit noch keine Nonce erhalten hat, kann der Client eine neue Nonce anfragen. Dazu schickt der Client einen HEAD-Request an den Server an die über das Directory erhaltene URL. Da jede Kommunikation, die nun beschrieben wird, eine "Replay"-Nonce verwendet, wurde darauf verzichtet, dies immer wieder anzuführen. Wie der HEAD-Request und die entsprechende Antwort dabei aussehen, wird im Listing 2.2.2.1 ("7.2 Getting a Nonce") verdeutlicht. Der erste Teil beschreibt eine Anfrage zum Erhalten der Nonce, der zweite Teil die entsprechende Antwort des Servers.

\definecolor{delim}{RGB}{20,105,176}
\definecolor{numb}{RGB}{106, 109, 32}
\definecolor{string}{rgb}{0.64,0.08,0.08}

\lstdefinelanguage{json}{
    frame=single,
    rulecolor=\color{black},
    showspaces=false,
    showtabs=false,
    breaklines=true,
    postbreak=\raisebox{0ex}[0ex][0ex]{\ensuremath{\color{gray}\hookrightarrow\space}},
    breakatwhitespace=true,
    basicstyle=\ttfamily\small,
    upquote=true,
    morestring=[b]",
    stringstyle=\color{string},
}
\lstset{language=JSON}
\begin{lstlisting}[caption={ '7.2 Getting a Nonce', RFC8555}, captionpos=b]
   HEAD /acme/new-nonce HTTP/1.1
   Host: example.com

   HTTP/1.1 200 OK
   Replay-Nonce: oFvnlFP1wIhRlYS2jTaXbA
   Cache-Control: no-store
   Link: <https://example.com/acme/directory>;rel="index"
\end{lstlisting}

#### Konto erstellen
Jede Order wird fest an ein Konto gebunden und so muss zu Beginn ein neues Konto erstellt werden. Dazu sendet der Client in seiner "JWS Payload" Mailadressen, die mit diesem Konto verknüpft werden sollen, sowie eine Bestätigung an den Server, dass der Client mit den Nutzungsbedingungen einverstanden ist. Optional kann in diesem Schritt auch ein bereits vorhandenes Konto verknüpft werden. Wie im folgenden Listing zu sehen, wird hier, da noch keine "Key ID" (KID) vorhanden ist, im Header an dessen Stelle der "JSON Web Key" (JWK) mit dem entsprechendem öffentlichen Schlüssel, der zum Signieren verwendet wurde, an den Server gesendet. Dieses Listing beschreibt dabei den Inhalt einer Anfrage zur Erstellung eines Kontos, wie er im RFC8555 definiert wird.

\begin{lstlisting}[caption={'7.3 Account Management' (Teil 1), RFC8555}, captionpos=b]
"protected": base64url({
  "alg": "ES256",
  "jwk": {...},
  "nonce": "6S8IqOGY7eL2lsGoTZYifg",
  "url": "https://example.com/acme/new-account"
}),
"payload": base64url({
  "termsOfServiceAgreed": true,
  "contact": [
    "mailto:cert-admin@example.org",
    "mailto:admin@example.org"
  ]
}),
"signature": "RZPOnYoPs1PhjszF...-nh6X1qtOFPB519I"
\end{lstlisting}

Die Antwort des Servers wird musterhaft im nächsten Listing dargestellt. Dabei übersendet der Server neben den "contact"-Informationen, die er vom Client erhalten hat, auch den Status sowie die URL für die entsprechende Order mit. Im Header der Antwort übersendet der Server dem Client auch seine Konto-URL, welche im folgenden Ablauf der Client-Server-Kommunikation als KID fungiert.

\begin{lstlisting}[caption={'7.3 Account Management' (Teil 2), RFC8555}, captionpos=b]
{
  "status": "valid",

  "contact": [
    "mailto:cert-admin@example.org",
    "mailto:admin@example.org"
  ],

  "orders": "https://example.com/acme/acct/evOfKhNU60wg/orders"
}
\end{lstlisting}

#### Order platzieren
Mit den im letzten Schritt erhaltenen Informationen kann der Client nun eine Order erstellen. Dazu sendet er in der "payload" ein "identifier"-Array mit allem, was er validiert haben möchte, an den Server. In diesem Array wird nicht nur definiert, mit welchem Verfahren, dem sogenannten "type", die Validierung stattfinden soll, sondern auch gegen welchen Wert ("value"). Der Client kann sich aussuchen, wie er geprüft werden möchte. Die prominentesten zwei Verfahren, die DNS- sowie die HTTP-Challenge, werden im nächsten Schritt näher erläutert. Für beide übersendet der Client im "type" des "identifier" den Wert "dns" mit, wie im Listing 2.2.2.3 zu sehen.
Zusätzlich kann der Client durch das Übersenden von "notBefore"- und "notAfter"-Werten bestimmen, für welchen Zeitraum das Zertifikat gültig sein soll, das ist jedoch optional.
In der Antwort schickt der Server den Status, wann die Gültigkeit der Anfrage ausläuft, sowie ein Array an Links zur Validierung der Order mit. Für jeden "identifier" mit "type" und "value" wird im sogenannten "authorizations"-Array genau ein Link erstellt. Zusätzlich antwortet der Server mit einer "finalize"-URL, die im späteren Verlauf benötigt wird.

\begin{lstlisting}[caption={'7.4 Applying for Certificate Issuance', RFC8555}, captionpos=b]
{
  "protected": base64url({
    "alg": "ES256",
    "kid": "https://example.com/acme/acct/evOfKhNU60wg",
    "nonce": "5XJ1L3lEkMG7tR6pA00clA",
    "url": "https://example.com/acme/new-order"
  }),
  "payload": base64url({
    "identifiers": [
      { "type": "dns", "value": "www.example.org" },
      { "type": "dns", "value": "example.org" }
    ],
    "notBefore": "2016-01-01T00:04:00+04:00",
    "notAfter": "2016-01-08T00:04:00+04:00"
  }),
  "signature": "H6ZXtGjTZyUnPeKn...wEA4TklBdh3e454g"
}
\end{lstlisting}

#### Challenge aktivieren
Für den Client gibt es mehrere Methoden, mit denen er beim Server validieren kann, dass er tatsächlich die Identität besitzt, die er vorgibt zu haben. Im RFC8555-Dokument werden dabei zwei Methoden näher erläutert, die auch hier ausführlicher besprochen werden sollen, die HTTP- und die DNS-Challenge. Weiterführend gibt es Erweiterungen für das Dokument, wie eine Challenge, welche die Kontrolle über eine IP-Adresse[@rfc-8738], oder die Domain über TLS, prüft [@rfc-8737]. Um zu verstehen, wie ACME funktioniert, reicht es aber aus, sich auf DNS- und HTTP-Challenge zu beschränken.

Der Client sendet nun einen POST-as-GET-Request an den Server unter der URL, deren Challenge er als erstes bearbeiten möchte.
Der Server antwortet nun mit Informationen zu dieser Challenge, wie dem Status, wann sie abläuft, den entsprechenden "identifier"-Werten und einem Array mit Challenges. Diese Challenges haben als Wert für den "type" entweder "http-01" oder "dns-01". Beide haben eine eigene URL sowie einen gemeinsamen Token. Der Token ist ein zufälliger base64-Wert, der die Challenge eindeutig identifiziert. Die im Folgenden verwendeten Beispiele stammen aus dem RFC8555-Dokument.

In der DNS-Challenge kann der Client aus diesem Token in Verbindung mit seinem eigenen kontogebundenen Schlüssel (Account Key), einen Autorisierungsschlüssel (Authorization Key) erstellen. Dieser Schlüssel wird anschließend mit dem SHA-256-Verfahren verschlüsselt (hashed). Der so erhaltene Wert wird nun als base64-Wert in einem "TXT Resource Record" im DNS gespeichert. Dieser Wert wird dabei unter dem Wert, der im "value" des "identifier"-Arrays angegeben wurde, nach dem Präfix "\_acme-challenge" abgespeichert. Für "www.example.org" wird der Wert also unter "\_acme-challenge.www.example.org" abgespeichert. Der Client sendet nun einen POST-as-GET-Request zum Server, um diesen zu informieren, dass dieser die Information anfragen kann.

Die HTTP-Challenge läuft sehr ähnlich ab. Hier wird genauso ein Autorisierungsschlüssel erstellt, nur wird dieser Schlüssel unter "[domain]/.well-known/acme-challenge/[token]" für einen GET-Request zur Verfügung gestellt.

#### Challenge erfüllen
Der Client sendet nun einen POST-as-GET-Request an den Server, um ihn wissen zu lassen, dass er mit der Validierung beginnen kann. Um zu validieren, dass die Challenge erfüllt wurde, erstellt der Server denselben Hash, fragt von der Domain das "TXT Resource Record" oder die HTTP-Ressource an und überprüft, dass der erhaltene Wert mit dem eigenen Wert übereinstimmt. Konnte der Wert abgefragt werden und stimmt er mit dem erstellten Wert überein, gilt die Challenge als bestanden.

#### Zertifikatsmanagement
Um die entsprechenden URLs, die der Client benötigt, bereitzustellen, erweitert der Server Stück für Stück die Order. Wird der Status dieser Order als "valid" gesetzt, wurden also alle Challenges erfüllt, so fügt der Server der Order eine "finalize"-URL hinzu. Mit dieser URL kann der Client ein Zertifikat anfragen. Dazu sendet er dem Server einen "Certificate Signing Request" (CSR) an die "finalize"-URL. Der Server generiert nun anhand dieses CSR noch einmal die Order und fügt eine "certificate"-URL hinzu. Mithilfe dieser URL teilt der Server dem Client mit, wo das für ihn generierte Zertifikat bereitgestellt wird.

Um das Zertifikat anzufordern, muss der Client jetzt nur noch einen POST-as-GET-Request an die im letzten Schritt mitgeteilte URL senden. Der Server antwortet mit dem Zertifikat im Body der Antwort. Damit ist das Zertifikat erhalten und der Ablauf des Protokolls abgeschlossen.

#### Weitere mögliche Schritte
 Der Client kann nun über das erstellte Konto die Zertifikate aktualisieren lassen, ohne die Challenges noch einmal durchlaufen zu müssen. Der Client kann den Server bitten, das Konto zu löschen oder ein Zertifikat zu widerrufen. Auch ein sogenannter "Key Change" ist möglich, wenn der öffentliche und der private Schlüssel, die für das Konto und damit auch für die Kommunikation mit JWS verwendet wurden, geändert werden sollen. Dabei muss der Client den neuen Schlüssel in einer Nachricht verpacken, welche von dem alten Schlüssel signiert wurde.
