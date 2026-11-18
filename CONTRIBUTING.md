# Willkommen 
Hallo! Schön, dass du mitarbeiten möchtest. Akutell ist das Projekt nur für unsere Praktikumsgruppe im Modul Legacy- Systeme und Programiersprachen. Wenn du trotzdem hier drüber gestolpert bist und Interesse hast, schau doch in ein paar Monaten wieder vorbei. Ansonsten geht es mit den folgenden Themen weiter:
## Inhalt
- [Ressourcen](#ressourcen)
  - [Git lernen](#git-lernen)
  - [Templates](#templates)
  - [Tests](#tests)
  - [Änderungen](#änderungen)
  - [Entwicklungsumgebung](#entwicklungsumgebung)
- [How To's](#how-tos)
  - [Bug Report](#bug-report)
  - [Bug Fix](#bug-fix)
  - [Features Vorschlagen](#features-vorschlagen)
  - [Coding convententions und Style](#coding-convententions-und-style)
- [Sonstiges](#sonstiges)
  - [Code of Conduct](#code-of-conduct)
  - [Wo bekomme ich Hilfe?](#wo-bekomme-ich-hilfe)
# Ressourcen 
## Git lernen 
Für alle, die sich noch nicht mit Git auskennen: [learn git](https://git-scm.de/learn)

Oder etwas spielerischer: [learn git branching](https://learngitbranching.js.org)

## Templates
Templates helfen dabei Issues und Pull-Request Einheitlich und Detailliert zu halten. Bitte benutze diese, wenn Möglich und lasse die Templates nur bei Ausnahmen weg. Falls ein Template dir nicht passt, dann schlag gerne eine Verbesserung vor. 

Für Issues(User Storys, Bug Reports, Feature Request) haben wir Templates bereitgestellt. Diese findest du im `.github` Ordner. Oder du wirst mit einer Auswahl an Templates begrüßt sobald du einen Issue erstellst. 

Auch für die Pull-Request haben wir Templates, die dabei Helfen nichts zu vergessen, wenn du deine Änderungen anderen Präsentieren möchtest. 

## Tests
tbd.

## Änderungen einbringen
Aktuell sind, wie in der Einleitung beschrieben, Änderung der Praktikumsgruppe vorbehalten. Bis März 2027 werden deswegen alle von Außerhalb stammenden Anfragen abgelehnt. Unser Professor möchte uns ja Unabhängig bewerten können. Ideen und Verbesserungsvorschläge sind dennoch Willkommen. Davon kann man nie genug haben. Bitte als Issues einreichen.

Änderungen sollen als Pull Request eingereicht werden. Wenn eine Pull Request nicht aus einem bestehenden, priorisiertem Issue stammt werden diese abgelehnt. Wenn die Anforderungen nicht dem referenziertem Issue oder den Conventions folgenden werden Änderungen angefragt. Falls die Anforderungen aus dem Issue Fehlerhaft sein sollten, dann gerne erst den Issue diskutieren und danach die geänderten Anforderungen übernehmen. 

## Entwicklungsumgebung
# How To's
## Bug Report
## Bug Fix
## Features Vorschlagen 
## Coding convententions und Style 
### Conventional Commits

Die Einhaltung standardisierter Conventional Commits hilft dabei, die Projekthistorie lesbar zu halten, die Versionierung zu automatisieren und die Erstellung von Changelogs zu vereinfachen.

#### Format

```shell
git commit -m  "[TAG:scope] subject"
```

**Beispiel:**

```shell
git commit -m "[FEAT:nfc] add read functionality for space ships"
```

#### Was wird committet? (TAG)

Der Typ beschreibt die Absicht des Commits.

```txt
    FEAT:     Ein neues Feature für den Benutzer oder die Anwendung.
    FIX:      Ein Bugfix für den Benutzer oder die Anwendung.
    BUILD:    Änderungen, die das Build-System oder externe Abhängigkeiten betreffen.
    CHORE:    Routineaufgaben, Wartung oder Tooling-Änderungen, die keine Quellcode- oder Testdateien verändern.
    CI:       Änderungen an CI/CD-Konfigurationsdateien und Skripten.
    DOCS:     Ausschließliche Änderungen an der Dokumentation.
    STYLE:    Änderungen, die die Bedeutung des Codes nicht beeinflussen (Leerzeichen, Formatierung, fehlende Semikolons usw.).
    REFACTOR: Eine Codeänderung, die weder einen Fehler behebt noch ein Feature hinzufügt (z. B. Code-Restrukturierung, Umbenennung von Variablen).
    PERF:     Eine Codeänderung, die die Leistung verbessert.
    TEST:     Hinzufügen fehlender Tests oder Korrektur bestehender Tests.
```

#### Wo wird committet? (SCOPE)

Der Scope ist ein optionaler Tag, der den spezifischen Bereich, das Modul oder die Komponente der Codebasis angibt, auf die sich der Commit auswirkt. Er liefert den Reviewern sofortigen Kontext.

**Beispiel:**

- `sector`
- `db`
- `police`
- `upgrades`
- `docker`
- `readme`

> [!NOTE]
> Wenn ein Commit mehrere Scopes betrifft oder eine globale Änderung ist wird, kann der Scope komplett weggelassen werden (z. B. [CHORE] clean up unused files).

#### Wie wird es beschrieben? (MESSAGE)

Der **Betreff** enthält eine prägnante Beschreibung der Änderung. Um die Historie lesbar zu halten, gelten folgende Regeln:

- Auf Englisch schreiben: Verwende die englische Sprache.
- Imperativ im Präsens verwenden: Schreibe so, als würdest du der Codebasis einen Befehl erteilen. Verwende "add" (nicht "added" oder "adds"), "fix" (nicht "fixed" oder "fixes") oder "update" (nicht "updated").
- Fasse dich kurz: Beschränke die Betreffzeile auf maximal 50 Zeichen.
- Keine Großschreibung: Beginne den Betreff mit einem Kleinbuchstaben.
- Keine Interpunktion: Beende die Betreffzeile nicht mit einem Punkt (.).

#### Erweitert: Breaking Changes

Wenn ein Commit einen Breaking Change (eine Änderung, die die Abwärtskompatibilität bricht) einführt, wird ein Ausrufezeichen (`!`) direkt hinter die eckige Klammer gesetzt.

**Beispiel:**

```shell
git commit -m "[FEAT:server]! remove support for legacy nfc chips"
```

# Sonstiges
## Code of Conduct 
Den Code of Conduct findet ihr [hier.](CODE_OF_CONDUCT.md)
## Wo bekomme ich Hilfe? 