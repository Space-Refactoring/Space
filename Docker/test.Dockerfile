FROM debian:bookworm-slim

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        fpc \
        fp-units-fcl && \
    rm -rf /var/lib/apt/lists/*

CMD ["sh", "-c", "mkdir -p build && fpc -Fu./tests -FU./build -FE./build tests/TestRunner.lpr && ./build/TestRunner --all --format=plain"]