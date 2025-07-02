#!/bin/sh

# Famedly Rust Container entrypoint.
#
# Configures the runtime to be used for various CI jobs.

echo "Preparing Rust build environment"


if [ -n "${FRC_SSH_KEY}" ]; then
    echo "Setting up SSH"

    # Get an ssh agent running
    USER="$(whoami)"
    SSH_HOME="$(getent passwd "$USER" | cut -d: -f6)" # Is different from $HOME in docker containers, because github CI..
    eval "$(ssh-agent)" # This exports the socket to `SSH_AUTH_SOCK`

    # Import the SSH key from the secret.
    #
    # `echo` ensures there will be a newline at the end of the key.
    echo "${FRC_SSH_KEY}" | ssh-add -vvv -

    # Import host keys for GitHub and Gitlab
    mkdir -p "$SSH_HOME/.ssh"
    (
        ssh-keyscan -H gitlab.com
        ssh-keyscan -H github.com
    ) >> "$SSH_HOME/.ssh/known_hosts"
else
    echo "SSH key not specified; SSH not available in this run"
fi


if [ -n "${FRC_ADDITIONAL_PACKAGES}" ]; then
    echo "Installing additional packages: ${FRC_ADDITIONAL_PACKAGES}"
    # shellcheck disable=SC2086
    apt-get install -yqq --no-install-recommends ${FRC_ADDITIONAL_PACKAGES}
fi


echo "Configuring cargo"

CARGO_HOME="${HOME}/${CARGO_HOME}"
mkdir -p "${CARGO_HOME}"
cat << EOF > "${CARGO_HOME}/config.toml"
[term]
color = 'always'
[net]
git-fetch-with-cli = true
EOF

# Don't write anything for crates-io, since it is baked-in and cargo
# special cases on it so configuring it works differently anyway.
if [ -n "${FRC_CRATES_REGISTRY}" ] &&  [ "${FRC_CRATES_REGISTRY}" != "crates-io" ]; then
    case "${FRC_CRATES_REGISTRY}" in
        "famedly")
            FRC_CRATES_REGISTRY_INDEX="${FRC_CRATES_REGISTRY_INDEX:-ssh://git@ssh.shipyard.rs/famedly/crate-index.git}"
            ;;
        "")
            if [ -z "${FRC_CRATES_REGISTRY_INDEX}" ]; then
                echo "Error: Crate registry index URL not known for ${FRC_CRATES_REGISTRY}. Configure it using \$FRC_CRATES_REGISTRY_INDEX." > /dev/stderr
                exit 1
            fi
            ;;
    esac

    cat << EOF >> "${CARGO_HOME}/config.toml"
[registries.${FRC_CRATES_REGISTRY}]
index = "${FRC_CRATES_REGISTRY_INDEX}"
EOF
fi


if [ -n "${GITHUB_ENV}" ]; then
    echo "Exporting created environment variables"

    (
        echo "CARGO_HOME=${CARGO_HOME}"
        echo "SSH_AUTH_SOCK=${SSH_AUTH_SOCK}"
    ) >> "$GITHUB_ENV"
fi


echo "Preparations finished"
"$@"
