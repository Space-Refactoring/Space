# Conventional Commits

Die Einhaltung standardisierter Conventional Commits hilft dabei, die Projekthistorie lesbar zu halten, die Versionierung zu automatisieren und die Erstellung von Changelogs zu vereinfachen.

## Format

```shell
git commit -m  "TAG(SCOPE): MESSAGE"
```

**Beispiel:**

```shell
git commit -m "feat(auth): add new authentication method"
```

## Was wird committet? (TAG)

Der Typ beschreibt die Absicht des Commits.

```txt
    feat:     Ein neues Feature für den Benutzer oder die Anwendung.
    fix:      Ein Bugfix für den Benutzer oder die Anwendung.
    build:    Änderungen, die das Build-System oder externe Abhängigkeiten betreffen.
    chore:    Routineaufgaben, Wartung oder Tooling-Änderungen, die keine Quellcode- oder Testdateien verändern.
    ci:       Änderungen an CI/CD-Konfigurationsdateien und Skripten.
    docs:     Ausschließliche Änderungen an der Dokumentation.
    style:    Änderungen, die die Bedeutung des Codes nicht beeinflussen (Leerzeichen, Formatierung, fehlende Semikolons usw.).
    refactor: Eine Codeänderung, die weder einen Fehler behebt noch ein Feature hinzufügt (z. B. Code-Restrukturierung, Umbenennung von Variablen).
    perf:     Eine Codeänderung, die die Leistung verbessert.
    test:     Hinzufügen fehlender Tests oder Korrektur bestehender Tests.
```

## Wo wird committet? (SCOPE)

Der Scope ist ein optionaler Tag, der den spezifischen Bereich, das Modul oder die Komponente der Codebasis angibt, auf die sich der Commit auswirkt. Er liefert den Reviewern sofortigen Kontext.

**Beispiel:**

- Architektur-/Modelbasierte: `core`, `auth`, `api`, `ui`, `db`
- UI & Komponentenbasierte: `button`, `form`, `header`, `footer`, `modal`
- Datei-/Abhängigkeitsbasierte: `deps`, `readme`, `docker`

> [!NOTE]
> Wenn ein Commit mehrere Scopes betrifft oder eine globale Änderung ist wird, kann der Scope komplett weggelassen werden (z. B. fix: resolve global memory leak).

## Wie wird es beschrieben? (MESSAGE)

Der **Betreff** enthält eine prägnante Beschreibung der Änderung. Um die Historie lesbar zu halten, gelten folgende Regeln:

- Auf Englisch schreiben: Verwende die englische Sprache.
- Imperativ im Präsens verwenden: Schreibe so, als würdest du der Codebasis einen Befehl erteilen. Verwende "add" (nicht "added" oder "adds"), "fix" (nicht "fixed" oder "fixes") oder "update" (nicht "updated").
- Fasse dich kurz: Beschränke die Betreffzeile auf maximal 50 Zeichen.
- Keine Großschreibung: Beginne den Betreff mit einem Kleinbuchstaben.
- Keine Interpunktion: Beende die Betreffzeile nicht mit einem Punkt (.).

## Erweitert: Breaking Changes & Zusätzliche Details

Wenn ein Commit einen Breaking Change (eine Änderung, die die Abwärtskompatibilität bricht) einführt, füge direkt vor dem Doppelpunkt ein Ausrufezeichen (!) hinzu.

**Beispiel:**

```shell
git commit -m "feat(auth)!: remove deprecated login method"
```

Wenn der Commit mehr Erklärung erfordert, kannst du einen erweiterten Textkörper (Body) und eine Fußzeile (Footer) hinzufügen. Über die Kommandozeile geht das durch die Übergabe mehrerer `-m`-Flags oder durch das reine Ausführen von `git commit`, wodurch sich der Texteditor öffnet.

**Beispiel:**

```shell
git commit -m "fix(core): resolve memory leak in data processing" -m "This commit addresses a critical memory leak issue" -m "Resolves #123, #456"
```
