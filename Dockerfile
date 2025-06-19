FROM docker.io/rust:bookworm

ARG NIGHTLY_VERSION_DATE
ENV NIGHTLY_VERSION=nightly-$NIGHTLY_VERSION_DATE

RUN apt update -yqq \
     && apt install -yqq --no-install-recommends \
     build-essential cmake libssl-dev pkg-config git musl-tools jq xmlstarlet lcov protobuf-compiler libprotobuf-dev libprotoc-dev nats-server \
     && rustup toolchain add $NIGHTLY_VERSION --component rustfmt --component clippy --component llvm-tools-preview \
     && rustup toolchain add beta --component rustfmt --component clippy --component llvm-tools-preview \
     && rustup toolchain add stable --component rustfmt --component clippy --component llvm-tools-preview \
     && rustup default stable \
     && cargo install grcov \
                      cargo-cache \
                      cargo-llvm-cov \
                      cargo-deny \
                      sqlx-cli \
                      typos-cli \
                      conventional_commits_linter \
                      cargo-udeps \
                      cargo-nextest \
                      cargo-readme \
                      cargo-audit \
                      cargo-auditable \
                      cargo-license \
                      taplo-cli \
                      cargo-chef \
     && cargo cache -a
COPY cobertura_transform.xslt /opt/
