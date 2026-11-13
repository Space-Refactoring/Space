# Conventional Commits

Die Einhaltung standardisierter Conventional Commits hilft dabei, die Projekthistorie lesbar zu halten, die Versionierung zu automatisieren und die Erstellung von Changelogs zu vereinfachen.

## Format

```shell
git commit -m  "[TAG:scope] subject"
```

**Beispiel:**

```shell
git commit -m "[FEAT:nfc] add read functionality for space ships"
```

## Was wird committet? (TAG)

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

## Wo wird committet? (SCOPE)

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

## Wie wird es beschrieben? (MESSAGE)

Der **Betreff** enthält eine prägnante Beschreibung der Änderung. Um die Historie lesbar zu halten, gelten folgende Regeln:

- Auf Englisch schreiben: Verwende die englische Sprache.
- Imperativ im Präsens verwenden: Schreibe so, als würdest du der Codebasis einen Befehl erteilen. Verwende "add" (nicht "added" oder "adds"), "fix" (nicht "fixed" oder "fixes") oder "update" (nicht "updated").
- Fasse dich kurz: Beschränke die Betreffzeile auf maximal 50 Zeichen.
- Keine Großschreibung: Beginne den Betreff mit einem Kleinbuchstaben.
- Keine Interpunktion: Beende die Betreffzeile nicht mit einem Punkt (.).

## Erweitert: Breaking Changes

Wenn ein Commit einen Breaking Change (eine Änderung, die die Abwärtskompatibilität bricht) einführt, wird ein Ausrufezeichen (`!`) direkt hinter die eckige Klammer gesetzt.

**Beispiel:**

```shell
git commit -m "[FEAT:server]! remove support for legacy nfc chips"
```
