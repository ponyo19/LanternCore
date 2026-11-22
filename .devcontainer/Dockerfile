# ---- Stage 1: prebuilt Verilator ----
FROM verilator/verilator:v5.036 AS verilator

# ---- Stage 2: dev image ----
FROM ubuntu:jammy
ENV DEBIAN_FRONTEND=noninteractive

# Your packages (minus apt verilator) + Verilator runtime deps
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl wget git jq dbus-x11 \
      ghdl gtkwave iverilog universal-ctags \
      python3 python3-pip python3-dev \
      g++ make perl ccache numactl \
      libfl2 zlib1g zlib1g-dev libgoogle-perftools-dev && \
    rm -rf /var/lib/apt/lists/*

# Verilator 5.036
COPY --from=verilator /usr/local/bin/            /usr/local/bin/
COPY --from=verilator /usr/local/share/verilator /usr/local/share/verilator

# Verible: latest release, resolved at build time
# (override with: --build-arg VERIBLE_VERSION=v0.0-...)
ARG VERIBLE_VERSION=latest
RUN set -e; \
    ARCH=$(uname -m); [ "$ARCH" = "aarch64" ] && ARCH=arm64 || true; \
    if [ "$VERIBLE_VERSION" = "latest" ]; then \
      VERIBLE_VERSION=$(curl -fsSL https://api.github.com/repos/chipsalliance/verible/releases/latest | jq -r .tag_name); \
    fi; \
    [ -n "$VERIBLE_VERSION" ] && [ "$VERIBLE_VERSION" != "null" ] || { echo "Could not resolve Verible version"; exit 1; }; \
    echo "Installing Verible $VERIBLE_VERSION"; \
    curl -fsSL https://github.com/chipsalliance/verible/releases/download/${VERIBLE_VERSION}/verible-${VERIBLE_VERSION}-linux-static-${ARCH}.tar.gz \
      | tar -xz -C /usr/local --strip-components 1; \
    verible-verilog-format --version

# Python tools
RUN pip3 install --no-cache-dir \
      "cocotb==2.0.1" cocotb-test cocotbext-axi \
      flake8 isort pytest yapf numpy h5py