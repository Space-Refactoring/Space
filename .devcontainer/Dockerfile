FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

RUN apt-get update && apt-get -y install --no-install-recommends \
        fpc \
        lazarus \
        lazarus-src \
        python3-pip \
        git \
        make \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip3 install pre-commit --no-cache-dir

# Clone and compile
RUN git clone https://github.com/quadroid/jcf-pascal-format.git /tmp/jcf-quadroid \
    && lazbuild /tmp/jcf-quadroid/App/pascal_format.lpi \
    && JCF_BIN=$(find /tmp/jcf-quadroid -iname "pascal-format" | head -n 1) \
    && cp "$JCF_BIN" /usr/local/bin/jcf \
    && chmod +x /usr/local/bin/jcf \
    && rm -rf /tmp/jcf-quadroid
