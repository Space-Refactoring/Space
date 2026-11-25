FROM debian:bookworm-slim

ARG UID=1000
ARG GID=1000

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        fpc \
        fp-units-fcl && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd --system --gid ${GID} appgroup && \
    useradd --system --uid ${UID} --gid appgroup --home-dir /app --shell /usr/sbin/nologin appuser
    mkdir -p /app/build && \
    chown -R appuser:appgroup /app

USER appuser:appgroup

CMD ["sh", "-c", "mkdir -p build && fpc -Fu./tests -FU./build -FE./build tests/TestRunner.lpr && ./build/TestRunner --all --format=plain"]