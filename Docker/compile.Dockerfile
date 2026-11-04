FROM debian:bookworm-slim

ARG OS_TARGET=win32
ARG CPU_TARGET=i386
ARG CCOMPILER=ppcross386

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        fpc \
        fpc-source \
        lazarus \
        make \
        gcc \
        mingw-w64 \
        curl \
        ca-certificates && \
    export FPCVER=$(fpc -iV) && \
    mkdir -p /tmp/fpc-src && \
    curl -L "https://downloads.freepascal.org/fpc/dist/${FPCVER}/source/fpc-${FPCVER}.source.tar.gz" \
         | tar -xz -C /tmp/fpc-src --strip-components=1 && \
    cd /tmp/fpc-src && \
    make clean all OS_TARGET=${OS_TARGET} CPU_TARGET=${CPU_TARGET} && \
    make crossinstall OS_TARGET=${OS_TARGET} CPU_TARGET=${CPU_TARGET} INSTALL_PREFIX=/usr && \
    ln -sf /usr/lib/fpc/$FPCVER/${CCOMPILER} /usr/bin/${CCOMPILER} && \
    echo "-Fu/usr/lib/fpc/${FPCVER}/units/\$fpctarget" >> /etc/fpc.cfg && \
    echo "-Fu/usr/lib/fpc/${FPCVER}/units/\$fpctarget/*" >> /etc/fpc.cfg && \
    echo "-Fu/usr/lib/fpc/${FPCVER}/units/\$fpctarget/rtl" >> /etc/fpc.cfg && \
    rm -rf /tmp/fpc-src && \
    apt-get remove -y curl ca-certificates && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*