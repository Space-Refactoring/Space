# Achitektur Dokumentation

## Generelle Übersicht

### Datei-Erklärung

Hier eine kurze Erklärung und Beschreibung der Dateien und wofür sie da sind.

|   Datei   | Kurzbeschreibung                                                                                                                                                                                                                      |
|:---------:|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| space.lpr | der Einstiegspunkt: Hier beginnt das Programm. Es startet die grafische Oberfläche und lädt das Hauptfenster.                                                                                                                         |
| Unit1.pas | der Hauptteil der Spiellogik: unter anderem RFID-Eingabe, Spieler- und Schiffsdaten, Aufträge, Be- und Entladen sowie Datei-Zugriffe. .pas ist hier schlicht die Pascal-Quellcodedatei.                                               |
| Unit1.lfm | der Bauplan des Hauptfensters: welche Elemente wie Labels, Eingabefelder und Anzeigen es gibt und wo sie liegen. Die Datei enthält nicht die eigentliche Spiellogik. (Winform)                                                        |
| space.lpi | die Projektdatei für Lazarus. Sie legt unter anderem fest, welche Dateien zum Projekt gehören und für welches Zielsystem gebaut wird. Lazarus ist die Entwicklungsumgebung, mit der das Programm gepflegt und kompiliert werden kann. |
| space.ini | Einstellungen für den konkreten Rechner: Sektor-Nummer und Pfade zu Laufwerk sowie Server-Verzeichnissen. So kann dieselbe Programmversion auf verschiedenen Sektor-Rechnern unterschiedlich eingerichtet werden.                     |
| use.bat   | ein Windows-Hilfsskript zum Verbinden von Netzlaufwerken; es ist keine Spiellogik.                                                                                                                                                    |

### Nicht mehr benötigte Dateien

- rfid.txt
- space.cfg
- space.dof
- Unit1.ddp

## Initiale Vorgehensweise

Das Programm wird erstmal in Bestandteile zerlegt.  
Jedes einzelne Segment kriegt seinen eigenen Unterordner.  
Die einzelnen Bestandteile werden später wieder passend zusammengeführt.  

Die Bestandteile sind:

- Datenhaltung
- Darstellung
- Spiellogik
  - Sektoren
    - (Il-)Legal
    - Werft
  - Events
  - Polizei
  - Auswertung

## Architekturideen

Allgemein gibt es mehrere Endpunkte, als die eine Anwendung fungieren kann:

- Sektor
  - Legal
  - Illegal
  - Werft
- Polizei
- Datenbank

Es muss festgelegt werden, als welcher eine ausgeführte Anwendung fungiert und auf welchen Datenendpunkt alle am Ende zugreifen.

### Einzelprogram

Alles wird in eine Anwendung kompiliert.
Beim Aufsetzen des Spiels kann man auswählen, welche Funktion die aktuelle Anwendung ausführen soll.

### Individuelle Programme

Jeder Endpunkt wird in ein eigenes Programm kompiliert.  
Je nach gewollten Nutzen wird das entsprechende Programm auf einem Gerät ausgeführt.
