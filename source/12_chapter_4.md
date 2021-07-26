# Ablauf

Die Kommunikation zwischen Client und Server wird durch Replay-noncen sowie durch JWS gesichert. Um die Kommunikation zu initialisieren muss der Client eine Replay-Nonce vom Server erfragen und zusätzlich ein Schlüssel paar erstellen. Der Öffentliche Schlüssel wird dabei zum Signieren der Nachrichten verwendet wohingegen mit dem Privaten Teil die Nachricht verschlüsselt wird mit einem ebenso anzugebenen Verfahren. (TODO: prüfen ob das stimmt, TODO: Prüfen ob das schon in Grundlagen abgedeckt werden kann). Jeder ACME Server beinhaltet eine URL die per Browser auch ohne Verschlüsselungen oder Replay-noncen erreicht werden kann, bei pebble ist das unter /14000/dir. Hier kann unter anderem Ausgelesen werden mit welcher URL ein Get-Account request erstellt werden kann.

Da jeder Request mit JWS verschlüsselt wird und jedes mal eine Replay Nonce mitgeschickt wird, welche der Servers im letzten Response mitgeschickt hat, wird darauf verzichtet dies bei jedem Schritt erneut zu erwähnen.

Es gibt im ACME Protokol keinen GET Request, da dieser keine Payload und damit auch keine Sicherheit bieten würde. Jeder Request der als GET Request fungieren soll ist tatsächlich nur ein POST Request in dem die Payload des JWS leer ist. Die einzige Ausnahme hierzu stellt die Anfrage an die Übersichtsseite /14000/dir.

### Account erstellen
Client: Die Payload des Get-Account requests beinhaltet neben einem Array an Mail Addressen die mit diesem Konto verknüpft werden sollen, nur eine bestätigung der TermsOfService.
Server: Der Server antwortet mit einem "201 Created" und teilt dem Client im Response Body die für ihn geltende Order-List-URL sowie seine Account-URL mit mit. Anhand dieser URL kann der Client eine Übersicht über seine aktuellen Order mithilfe eines POST-AS-GET Requestes erhalten.

### New-Certificate Request

Client: Nun können für diesen Account Zertifikate angefragt werden. Dazu sendet der Clinet in der Payload ein Array von Identfiern sowie ein NotBefore und NotAfter an den Server. Die Identfier bestehen aus einmal dem "Typ", also dem Ferfahren mit welchem die Verifiziert werden soll. Sowie einem Value gegen den getested werden kann. NotBefore steht für den frühsten Zeitpunkt in dem die Challenge stattfinden soll und NotAfter stellt die Zeitliche Obergrenze dar. (TODO: Prüfen ob notBefore und NotAfter stimmen).
Server: Der Sever antwortet mit "status", "expires", "notBefore", "notAfter", den Identifiern sowie "authorizations" und "finalize".

<!--
TODO:
- überlegen ob Values interessant sind oder weggelassen werden können
- Macht es Sinn als Beispiel DNS zu besprechen?
-->

### Start Challenge

Client: Durch den letzten Request kann der Client den Server nach der soeben




<!--
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
