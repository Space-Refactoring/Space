FROM debian:bookworm-slim

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      wine \
      wine32 \
      fonts-wine \
    && rm -rf /var/lib/apt/lists/*

ENV WINEPREFIX=/tmp/.wine
ENV WINEDEBUG=-all

WORKDIR /app

CMD ["wine", "space.exe"]