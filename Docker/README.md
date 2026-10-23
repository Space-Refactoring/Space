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

Wer keine Lust hat das ganze Pascal Zeug lokal zu installieren kann das Docker Image compile.Dockerfile benutzen. Das sollte nur einmal gebaut werden via `docker build --tag compile --file Docker/compile.Dockerfile Docker/`
Keine Sorge das dauert ein paar Minuten. Dafür müssen wir es nur einmal machen.
Danach kann `lazbuild` benutzt werden um das Projekt zu kompilieren. Der Befehl kann ganz einfach in kombination mit dem docker container benutzt werden: 
```shell
docker run --rm -v "$PWD":/app/ -w /app/ compile lazbuild --build-all --os=win32 --cpu=i386 --ws=win32 --lazarusdir=/usr/lib/lazarus /app/space.lpi
```
Danach sollten `space.exe` und weitere lustige Dateien im Verzeichnis auftauchen. 