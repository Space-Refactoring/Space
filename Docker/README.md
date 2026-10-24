# Projekt kompilieren

## Option A - Lokal kompilieren

Um das Projekt lokal zu kompilieren brauchen wir zuerst:

- `fpc` (free pascal compiler)
- `lazarus` (IDE)

Keine Angst, man muss nicht in Lazarus entwickeln, obwohl das keine schlecht Wahl ist. Allerdings brauchen wir einge Komponenten von Larazus um das Projekt zu bauen. Spezifischer aus der LCL(Lazarus Component Library).

Und der Compiler muss noch darauf ausgelegt werden überhaupt ins Zielsystem zu kompilieren. Unser Zielsystem ist:

- OS: `Win32`
- CPU: `i386`

Ja darauf muss man bei Pascal achten. Wieso ist das unser Zielsystem? Noch wollen wir nichts am Projekt ändern, also tragen wir die Last der Vergangenheit.

fpc kann nicht von natur aus cross-compilen. Das wäre ja zu einfach. Unzwar müssen wir dafür fpc selber kompilieren (deswegen dauert es ein wenig das Docker Image zu bauen). Wie das funktioniert steht in folgendem [Guide](https://lazplanet.blogspot.com/2020/05/cross-compile-on-lazarus.html) (Windows/Linux).

Danach entweder in Lazarus das Zielsystem unter Projekteinstellungen setzen und fröhlich kompilieren oder mittels lazbuild:

```shell
lazbuild --build-all --os=win32 --cpu=i386 --ws=win32 space.lpi
```

## Option B - Docker Container

Wer keine Lust hat, das ganze Pascal-Zeug lokal zu installieren, kann einfach Docker Compose nutzen. Wir haben das Setup in zwei Services aufgeteilt: einen zum Kompilieren und einen zum direkten Ausführen

### Kompilieren

Beim ersten Ausführen wird das Docker-Image gebaut (keine Sorge, das dauert nur einmalig ein paar Minuten). Anschließend wird das Projekt automatisch kompiliert:

```shell
    docker-compose run --rm compiler
```

Danach sollten die space.exe und weitere lustige Dateien im Verzeichnis auftauchen.

### Ausführen (Nur Linux/MacOS)

Um die kompilierte grafische Anwendung direkt im Container zu testen, leiten wir das Display an den X11-Server des Hosts weiter. Der Runner kann wie folgt gestartet werden:

```shell
    docker-compose run --rm runner
```

#### Linux

Der Container nutzt die $DISPLAY-Umgebungsvariable. Gegebenenfalls musst du vorher lokale Verbindungen zum X-Server mit xhost +local: erlauben, damit sich das Fenster öffnen darf.

#### MacOS

Auf MacOS ist die X11-Unterstützung nicht mehr standardmäßig vorhanden. Du musst vorher XQuartz installieren und starten. Danach kannst du in den Einstellungen von XQuartz unter "Security" die Option "Allow connections from network clients" aktivieren. Anschließend musst du in deinem Terminal die DISPLAY-Variable setzen:

```shell
    export DISPLAY=host.docker.internal:0
```
