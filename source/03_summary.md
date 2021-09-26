# Abstract {.unnumbered}

Diese Arbeit widmet sich der Fragestellung, wie X.509-Zertifikate für eindeutig identifizierte Linux-basierte Endbenutzersysteme sicher verteilt und ausgestellt werden können. Dazu wird in der Arbeit erst konzeptuell, dann anhand einer beispielhaften Implementierung besprochen, wie ein solches Verfahren umsetzbar ist. Durch seine vielfach getestete Architektur erlaubt die Verwendung des "Trusted Platform Module" dem Linux-basierten Endbenutzersystem, Zertifikate nicht nur sicher zu verwahren, sondern auch Identitäten zu speichern, die es ermöglichen, dieses System eindeutig zu identifizieren. Das "Automated Certificate Management Environment" ist ein Protokoll, das für eine verwandte Anwendung entwickelt wurde. Diese Arbeit erweitert nun das Protokoll, um ein Verfahren zur Verteilung von X.509-Zertifikaten anhand der im TPM-Chip gespeicherten Identitäten zu ermöglichen. Diese Implementierung wird auf ihre Benutzbarkeit evaluiert und es werden weiterführende Sicherheitsmaßnahmen erörtert.

\pagenumbering{gobble}
\setcounter{page}{1}

\newpage
