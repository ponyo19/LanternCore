#!/bin/bash
set -xe
 
apt update
DEBIAN_FRONTEND=noninteractive apt install -y \
    curl \
    dbus-x11 \
    git \
    ghdl \
    gcc-riscv64-unknown-elf \
    gtkwave \
    iverilog \
    jq \
    python3-pip \
    binutils-riscv64-unknown-elf \
    universal-ctags \
    wget \
    autoconf \
    bison \
    flex \
    g++ \
    help2man \
    libfl-dev \
    liblz4-dev \
    make \
    perl \
    zlib1g-dev 
pip3 install \
    cocotb \
    cocotb-test \
    cocotbext-axi \
    flake8 \
    isort \
    pytest \
    yapf \
    numpy \
    h5py
 
# Verible
ARCH=$(uname -m)
if [[ $ARCH == "aarch64" ]]; then
    ARCH="arm64"
fi
VERIBLE_RELEASE=$(curl -s -X GET https://api.github.com/repos/chipsalliance/verible/releases/latest | jq -r '.tag_name')
VERIBLE_TAR=verible-$VERIBLE_RELEASE-linux-static-$ARCH.tar.gz
VERIBLE_PREFIX="${VERIBLE_INSTALL_PREFIX:-${HOME}/.local}"
if [[ ! -f $VERIBLE_TAR ]]; then
    wget https://github.com/chipsalliance/verible/releases/download/$VERIBLE_RELEASE/$VERIBLE_TAR
fi
if ! command -v verible-verilog-format >/dev/null 2>&1; then
    mkdir -p "${VERIBLE_PREFIX}"
    tar -C "${VERIBLE_PREFIX}" --strip-components 1 -xf "$VERIBLE_TAR"
fi
rm "$VERIBLE_TAR"

VERILATOR_VERSION=v5.036
git clone --depth 1 --branch "$VERILATOR_VERSION" \
    https://github.com/verilator/verilator.git /tmp/verilator
(
    cd /tmp/verilator
    autoconf
    ./configure
    make -j"$(nproc)"
    make install
)
