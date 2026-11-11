# Featurevorschläge

## Spielfunktionalität

- 3D-gedruckte Raumschiffe um die Chips rum

- Warteschlange: Einloggen ist nicht instant, sondern per "landen"
  - Nach dem Landen auch mehrere Auswahlmöglichkeiten, was man machen will
- **Piraten**
  - In Kombination mit einer Warteschlange -> Greifen die in der Warteschlange an
  - Sind beim Landen sofort dran und können ein Schiff zum Angreifen aussuchen, müssen erbeutete Ware vom Auftrag n Illegalem Sektor verkaufen
  - Pirat werden ist Upgrade
  - **Kopfgeldjäger** als Konter zu Piraten
    - Live-Ticker mit öffentlichen Bounties
  - Strafe beim erwischt werden von Polizei
- **Werft** erweiterung: **Schiffupgrades**
  - Inkrementelle Upgrades
  - Upgradeideen
    - Beim Polizei/Pirat Scannen nicht entdeckt werden
    - Events günstiger
    - Führerschein -> Extra Strafe bei Polizeistop
      - Fragenkatalog -> Modifizierbar per Spielgruppe
    - Lagerraum
  - TÜV
  - Tanken
- Frachtraum
  - Begrenzter Frachtraum
  - Laderaumupgrades
  - Beladezeit - analog zur Frachtmenge
  - Traktorstrahlupgrades zum schnelleren Einladen
  - Lagerraum für exotische Fracht - Tiere, Kühlraum, Personen
- Handy ins Spiel einbringen
  - einsehen der Daten
  - Als Polizeigerät
- "Crime" - Level
  - Steigt an illegalen Stationen
  - Kann man an legalen langsam senken
  - Verbindbar mit Piraten und Kopfgeldjägern
- Zeitbasierte Aufträge
- Mining
  - Asteoridengürtel zum abbauen
  - Abbauen als Upgrade
  - Begrenzte Ressourcen
  - Muss abgrenzbar sein zu regulären Aufträgen
    - Gemeinschatsauftrag, Mining freizuschalten
- Underdog Boost
  - Möglichkeit, um wieder aufzuholen wenn man sehr niedrig ist
  - Höhere Spieler etwas niedriger machen
- Global Events/Gemeinschaftsaufträge
  - Ressourcen Sammeln und in der Werft einlagern
- Clans, Gilden, Fraktionen
- Flotten kommandieren
  - Mehr Schiffe dazukaufen
  - Einzelne Schiffe auf Aufträge loschicken
- Easter Eggs

### Kontrovers

- Selbstzerstörung
  - Schlag gegen alle in der Warteschlange
- Timeout bei Illegalem Theoretisch als Option

## Balancing

- Aufträge
  - Aufträge die am selben Sektor starten bringen weniger
  - über mehrere Stationen
  - Mehrere Aufträge parallel aufnehmen
    - Kombinierbar mit Lagerraum-Upgrades
  - Abbrechmöglichkeit
- Seperater Sektor, der Codes ausgibt
  - Codes nicht physisch, sondern in Datenbank gespeichert
- Ereignisse mit Werft verbinden
  - Schiff Kaputt -> Zur Werft zum reparieren
- Ereignis-Kosten mit dem Schiff level steigen

## Tech

- Gleichverteilung der Aufträge/Spieler auf die Sektoren
- Universelles Kompilieren auf alle Prozessorarchitekturen
- Dynamische Anzahl an Sektoren
- Vereinfachte Konfiguration der Sektoren

- Spielmodi
  - Simpler aktuelle Funktionalität
  - Komplex mit mehr interaktion
  - Einbindung als Spiel für die Uni-Erstiwoche

- Audio
- UI-Upgrade

- Winform gegen Browser-based austauschen

## Bugs

- Start und Zielsektor gleich
- Sonderzeichen anzeige (Unicode-Problem)
- GUI Bearbeitbar (über Tab)
- UI vom Controller lösen
- Datenverlust beim Dateilesen während ein Sektor schreiben will
