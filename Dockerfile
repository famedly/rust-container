FROM docker.io/rust:bookworm

ARG NIGHTLY_VERSION_DATE
ENV NIGHTLY_VERSION=nightly-$NIGHTLY_VERSION_DATE

# Add the docker apt repo.
#
# See instructions in the docker docs:
# https://docs.docker.com/engine/install/ubuntu/#installation-methods
RUN apt install ca-certificates curl \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list

# Note that we do not need docker engine as we mount a docker socket
# into the container
RUN apt update -yqq \
     && apt install -yqq --no-install-recommends \
     build-essential cmake libssl-dev pkg-config git musl-tools jq xmlstarlet lcov protobuf-compiler libprotobuf-dev libprotoc-dev \
     docker-ce-cli docker-compose-plugin docker-buildx-plugin \
     && rustup toolchain add $NIGHTLY_VERSION --component rustfmt --component clippy --component llvm-tools-preview \
     && rustup toolchain add beta --component rustfmt --component clippy --component llvm-tools-preview \
     && rustup toolchain add stable --component rustfmt --component clippy --component llvm-tools-preview \
     && rustup default stable \
     && cargo install grcov \
     && cargo install cargo-cache \
     && cargo install cargo-llvm-cov \
     && cargo install cargo-deny \
     && cargo install sqlx-cli \
     && cargo install typos-cli \
     && cargo install conventional_commits_linter \
     && cargo install cargo-udeps --locked \
     && cargo install cargo-nextest \
     && cargo install cargo-readme \
     && cargo install cargo-audit \
     && cargo install cargo-auditable \
     && cargo install cargo-license \
     && cargo cache -a

COPY cobertura_transform.xslt /opt/
COPY docker.json /etc/docker/daemon.json

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
