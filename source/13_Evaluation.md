# Evaluation

## Testlauf der ACME Erweiterung

## Vergleich mit DNS und HTTP Challenges

## Angriffsvektoren
<!--
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

-->
### Mögliche Angriffe

### Schutzmechanismen

## Mögliche Erweiterungen



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
