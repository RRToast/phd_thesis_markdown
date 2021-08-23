<!--
  Zentrale Variablen:
  Workaround bzw. Rückgriff auf LaTex-Befehle, um zentrale Werte immer wieder verwenden zu können.
-->
% Abschlussarbeit
\newcommand{\titel}{Sichere Verteilung von X.509-Zertifikaten auf Linux-basierten Endbenutzersystemen}
\newcommand{\datum}{01.03.2018}

% Autor_in
\newcommand{\aVorname}{Richard}
\newcommand{\aNachname}{Reik}
\newcommand{\aGeburtsdatum}{27.08.1998}
\newcommand{\aInstitution}{Hochschule München}
\newcommand{\aStudiengruppe}{IF8}
\newcommand{\aSemester}{SS 2021}

\newcommand{\aName}{\aVorname\space \aNachname}

% Prüfer_in
\newcommand{\pTitle}{Prof. Dr.-Ing.}
\newcommand{\pVorname}{Thomas}
\newcommand{\pNachname}{Schreck}
\newcommand{\pInstitution}{Hochschule München}

% Betreuer_in
\newcommand{\bTitle}{Dr.}
\newcommand{\bVorname}{}
\newcommand{\bNachname}{}
\newcommand{\bInstitution}{Firma GmbH}

\title{\titel}
\author{\aName}

<!--
  Titelseite
-->

\begin{titlepage}
    \begin{center}

        \includegraphics[width=1\textwidth]{style/hm-fk07_logo.jpg}

        \vspace*{1.0cm}

        \LARGE
        \titel

        \vspace{1.5cm}

        \Large
        \aName

        \vspace{0.5cm}

        \normalsize
        Bachelorarbeit Informatik

        \vfill

        \normalsize
        Prüfer:\\
        \pTitle\space \pVorname\space \pNachname,\space \pInstitution

        \vspace{0.5cm}

        % Firmenlogo
        % \includegraphics[width=0.4\textwidth]{style/firmenlogo.png}

        \normalsize
        Betreuer:\\
        \bTitle\space \bVorname\space \bNachname,\space \bInstitution

        % Abgabedatum
        \datum

    \end{center}
\end{titlepage}
