FROM archlinux:base

ARG OS_TARGET=win32
ARG CPU_TARGET=i386
ARG CCOMPILER=ppcross386

WORKDIR /app

RUN echo "DisableSandboxSyscalls" >> /etc/pacman.conf && \
    pacman -Syu --noconfirm && \
    pacman -S --needed --noconfirm \
        fpc fpc-src lazarus \
        make gcc mingw-w64-gcc && \
    export FPCVER=$(fpc -iV) && \ 
    cd /usr/lib/fpc/src/ || cd /usr/share/fpcsrc/$FPCVER &&\ 
    make clean all OS_TARGET=${OS_TARGET} CPU_TARGET=${CPU_TARGET} && \
    make crossinstall OS_TARGET=${OS_TARGET} CPU_TARGET=${CPU_TARGET} INSTALL_PREFIX=/usr && \
    ln -sf /usr/lib/fpc/$FPCVER/${CCOMPILER} /usr/bin/${CCOMPILER} && \
    rm -rf /var/cache/pacman/pkg/* /var/lib/pacman/sync/*
