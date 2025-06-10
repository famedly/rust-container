FROM docker.io/rust:bookworm

ARG NIGHTLY_VERSION_DATE
ENV NIGHTLY_VERSION=nightly-$NIGHTLY_VERSION_DATE

RUN apt update -yqq
RUN apt install -yqq --no-install-recommends \
        build-essential cmake libssl-dev pkg-config git musl-tools jq yq \
        lcov protobuf-compiler libprotobuf-dev libprotoc-dev

RUN rustup toolchain uninstall $(rustup toolchain list -q)
RUN rustup toolchain add stable --component clippy --component llvm-tools-preview
RUN rustup toolchain add $NIGHTLY_VERSION --component rustfmt --component clippy
RUN rustup default stable

RUN cargo install --locked \
  cargo-cache \
  cargo-llvm-cov \
  cargo-deny \
  typos-cli \
  cargo-udeps \
  cargo-nextest \
  cargo-audit \
  cargo-auditable \
  taplo-cli

RUN cargo cache -a
