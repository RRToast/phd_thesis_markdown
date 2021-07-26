# Architektur

Zur Darstellung der Umsetzung der erweiterung zum ACME Protokol ist es wichtig voher zu erklären wie eine ACME Challenge aussieht und an welchen Punkten angesetzt werden kann. Dabei soll auch verdeutlicht werden welche Gefahren und Herrausforderungen bei jeder Änderung negiert oder hinzugefügt werden. Dabei werden zuerste die Hintergründe geklärt bevor das Verfahren anhand der DNS Challenge beschrieben werden soll.

## Hintergründe
### ACME
ACME steht für Automatic Certificate Management Enviroment. Wie der Name schon vermuten lässt handelt es sich hierbei um Software die Verwendet werden kann um Zertifikate automatisch ausstellen und verwalten zu können. Die Idee hierzu stammt aus der lästig werdenden Handarbeit die Entsteht wenn für mehrer Server per Hand eine neues Zertifikate ausgestellt werden soll. Das Verfahren wird im RFC-8555 definiert und stellt neben einer internen CA zum austellten von Zertifikaten auch ein Validierungssystem dar, mit dessen Hilfe sichergestellt werden kann dass nur die korrekten Instanzen ein Zertifikat erhalten.

### Nonce
ACME verwendet Replay Noncen um sicher zu stellen dass die Anwendung vor Replay Angriffen geschützt ist. Auf jede valide Anfrage an den Server antwortet dieser mit einer Replay Nonce im JWS Header, welche für den nächsten Request verwendet werden kann. Da dieses Prinzip für jede Anfrage gilt wird sie im weiteren Verlauf der Bachelorarbeit nicht explizit für jeden Schritt im Protokol genannt.

### JWS
Um unnötige Informationen zu vermeiden soll auch hier im weiteren Verlauf nicht weiter aufgelistet werden wie die Signatur aussieht oder welche Header mitgeschickt werden. Die Ausnahme stellen hier Informationen die dem Client über den Header des Server Requests mitgeschickt werden.

## Schritt 0: Die erste Nonce
Wie im vorheringen Absatz beschrieben wird die Nonce vom Server zur verwendung mitgeschickt, allerdings falls diese veraltet oder noch kein Valider Request gesendet wurde braucht es eine Möglichkeit Replay Noncen abzufragen. Dazu stellt jeder ACME Server eine kleine Übersicht mit allen Relevanten URLs zur Verfügung. Darunter befindet sich auch eine URL um einen Account zu erstellen, sowie eine um eine Nonce anzufragen.
Jede ACME Kommunikation beginnt also mit dem anfragen der Replay-Noncen URL.

## Schritt 1: Account erstellen
Jeder Request wird fest an einen Account gebunden und so muss, falls das noch nicht in einere anderen Session passiert ist ein neuer Account erstellt werden. Dazu sendet der Client in seiner JWS Payload Mail addressen die mit diesem Account verknüpft werden sollen, sowie eine Bestätigung das der Client mit den Nutzungsbedinugen einverstanden ist. Optional kann hier auch ein bereits vorhandenes Konto verknüpft werden. Da noch keine KID vorhanden ist wird hier im Header an dessen Stelle JWK mit dem entsprechendem Privaten Schlüssel an den Server gesendet.
Der Server antwortet in der Payload mit dem Status des Accounts, sowie mit der KID des Client und der entsprechenden URL des Accounts.

## Schritt 2: Order platzieren
Mit den Informationen aus Schritt 1 kann der Client nun eine Order aufgeben. Dazu sendet er in der Payload ein Array mit allen Ordern die er aufgeben möchte, sowie einen Zeitlichen Rahmen in dem die Validierung durchgeführt werden soll, an den Server. Dabei wird in dem Array nicht nur definiert mit welchem Verfahren sondern auch mit gegen welchen Wert die Validierung stattfinden soll.
In der Antwort schickt der Server den Status, wann die Anfrage ungültig wird, sowie ein Array an Links zur Validierung der Order. Für jede Order wird ein Link erstellt. Zusätzlich antwortet der Server mit einer Finalisierungs URL die im späteren Verlauf benötigt wird.

## Schritt 3: Challenge aktivieren
Je nachdem um welchen Typ von Challenge es geht ist dieser Schritt unterschiedlich. Bei der DNS Challenge wird nun eine Nachricht an den Server geschickt um ihn wissen zu lassen das jetzt eine Validierung durchgeführt werden kann. Der Server antwortet mit einem Wert den der Client entschlüsselt in einem TXT Dokument, für den Server zugänglich abspeichert. Der Server kann nun dieses Dokument anfragen und so bestimmen das der Client tatsächlich die Kontrolle über die angegebene DNS besitzt.

## Schritt 4: Challenge erfüllen
Auch dieser Schritt ist abhängig von der jeweiligen Challenge, grob kann gesagt werden dass die Challenge erfüllt wird und der Server den Status für diese Challenge anpasst.

## Schritt 5: CSR wird an den Server geschickt
Wird der Status für diese Order als Valide erkannt, also alle Challenges wurden erfüllt, so kann der Client sein Certifikat anfragen. Dazu sendet er dem Server eine CSR aus welcher dieser ein Certifkat erstellt.

## Schritt 6: Certifikat wird erhalten
Das im Schritt 5 erstellte Zertifikat wird auf dem Server gespeichert und kann vom Client angefordert werden. Dazu sendet er einen POST-AS-GET Request an die im letzten Schritt mitgeteilte URL. Der Server Antwortet mit dem Certifiat im Body der Antwort.

## Weitere mögliche Schritte
Damit ist die Kommunikation abgeschlossen. Der Client kann nun über den erstellten Account die Certifikate aktualisieren lassen, ohne die Challenges noch einmal durchlaufen zu müssen. Der Client kann den Server bitten den Account zu löschen oder ein Certifikat zu wiederrufen.

<!--
## Einleitung

Das ist die Einleitung. Nam mollis congue tortor, sit amet convallis tortor mollis eget. Fusce viverra ut magna eu sagittis. Vestibulum at ultrices sapien, at elementum urna. Nam a blandit leo, non lobortis quam. Aliquam feugiat turpis vitae tincidunt ultricies. Mauris ullamcorper pellentesque nisl, vel molestie lorem viverra at.

## Methode

Suspendisse iaculis in lacus ut dignissim. Cras dignissim dictum eleifend. Suspendisse potenti. Suspendisse et nisi suscipit, vestibulum est at, maximus sapien. Sed ut diam tortor.

### Unterabschnitt 1 mit Beispielcode

Das ist der erste Teil der Methodik. Cras porta dui a dolor tincidunt placerat. Cras scelerisque sem et malesuada vestibulum. Vivamus faucibus ligula ac sodales consectetur. Aliquam vel tristique nisl. Aliquam erat volutpat. Pellentesque iaculis enim sit amet posuere facilisis. Integer egestas quam sit amet nunc maximus, id bibendum ex blandit.

Syntaxhervorhebung in Codeblöcken erreicht man mit drei "`" Zeichen vor und nach dem Codeblock.

```python
mood = 'happy'
if mood == 'happy':
    print("I am a happy robot")
```

### Unterabschnitt 2

Das ist der zweite Teil der Methodik. Proin tincidunt odio non sem mollis tristique. Fusce pharetra accumsan volutpat. In nec mauris vel orci rutrum dapibus nec ac nibh. Praesent malesuada sagittis nulla, eget commodo mauris ultricies eget. Suspendisse iaculis finibus ligula.

<!--
Kommentare können so hinzugefügt werden.

## Ergebnisse

Das sind die Ergebnisse. Ut accumsan tempus aliquam. Sed massa ex, egestas non libero id, imperdiet scelerisque augue. Duis rutrum ultrices arcu et ultricies. Proin vel elit eu magna mattis vehicula. Sed ex erat, fringilla vel feugiat ut, fringilla non diam.

## Auseinandersetzung

Das ist die Auseinandersetzung mit den Ergebnissen. Duis ultrices tempor sem vitae convallis. Pellentesque lobortis risus ac nisi varius bibendum. Phasellus volutpat aliquam varius. Mauris vitae neque quis libero volutpat finibus. Nunc diam metus, imperdiet vitae leo sed, varius posuere orci.

## Schlussfolgerung

Das ist die Schlussfolgerung des Kapitels. Praesent bibendum urna orci, a venenatis tellus venenatis at. Etiam ornare, est sed lacinia elementum, lectus diam tempor leo, sit amet elementum ex elit id ex. Ut ac viverra turpis. Quisque in nisl auctor, ornare dui ac, consequat tellus.

-->
