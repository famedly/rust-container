FROM docker.io/rust:slim-bookworm

ARG NIGHTLY_VERSION_DATE
ENV NIGHTLY_VERSION=nightly-$NIGHTLY_VERSION_DATE

# apt dependencies
## Run in one layer to avoid caching issues
RUN apt update -yqq && apt install -yqq --no-install-recommends \
     build-essential \
     cmake \
     curl \
     git \
     jq \
     lcov \
     libprotobuf-dev \
     libprotoc-dev \
     libssl-dev \
     musl-tools \
     nats-server \
     pkg-config \
     protobuf-compiler \
     yq \
     && apt-get clean && rm -rf /var/lib/apt/lists/*

# cargo dependencies
RUN cargo install cargo-binstall --locked && cargo binstall --locked --no-confirm --disable-telemetry \
     cargo-audit \
     cargo-auditable \
     cargo-cache \
     cargo-chef \
     cargo-deny \
     cargo-llvm-cov \
     cargo-nextest \
     cargo-udeps \
     sqlx-cli \
     taplo-cli \
     typos-cli \
     && cargo cache --autoclean

# rustup dependencies
## added to default stable toolchain
RUN rustup component add clippy llvm-tools-preview
## add nightly toolchain
RUN rustup toolchain add $NIGHTLY_VERSION --component rustfmt --component clippy
