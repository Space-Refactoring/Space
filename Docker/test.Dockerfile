FROM debian:bookworm-slim

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        fpc \
        fp-units-fcl && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd --system appgroup && \
    useradd --system --gid appgroup --home-dir /app appuser && \
    mkdir -p /app/build && \
    chown -R appuser:appgroup /app

USER appuser:appgroup

CMD ["sh", "-c", "mkdir -p build && fpc -Fu./tests -FU./build -FE./build tests/TestRunner.lpr && ./build/TestRunner --all --format=plain"]