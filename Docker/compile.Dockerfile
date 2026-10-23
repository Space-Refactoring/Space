FROM archlinux 

ARG OS_TARGET=win32
ARG CPU_TARGET=i386
ARG CCOMPILER=ppcross386

WORKDIR /app/

# Für andere Target Architekturen hier ggf. bibliotheken hinuzfügen
RUN pacman -Syu --noconfirm && \
    pacman -S --needed --noconfirm \
      fpc fpc-src lazarus \
      base-devel git mingw-w64-gcc && \
    pacman -Scc --noconfirm

RUN export FPCVER=`fpc -iV` && \ 
    cd /usr/lib/fpc/src/ || cd /usr/share/fpcsrc/$FPCVER &&\ 
    make clean all OS_TARGET=${OS_TARGET} CPU_TARGET=${CPU_TARGET} &&\
    make crossinstall OS_TARGET=${OS_TARGET} CPU_TARGET=${CPU_TARGET} INSTALL_PREFIX=/usr && \
    ln -sf /usr/lib/fpc/$FPCVER/${CCOMPILER} /usr/bin/${CCOMPILER}

LABEL maintainer="louis.krumme@hsbi.de"

