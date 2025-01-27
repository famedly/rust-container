# Famedly Rust Container

Container used for Rust CI jobs. Set up with all necessary packages
and configuration to build, test and publish our crates.

For full environment setup, some secrets need to be defined:

## Settings

| Variable                     | Example Value                                     | Explanation |
|------------------------------|---------------------------------------------------|-------------|
| FRC_ADDITIONAL_PACKAGES      | libxml2 dbus                                      | Additional ubuntu packages to install before running the given command. |
| FRC_CRATES_REGISTRY          | famedly                                           | Additional registry to pull crates from.                              |
| FRC_CRATES_REGISTRY_INDEX    | ssh://git@ssh.shipyard.rs/famedly/crate-index.git | The index URL of the registry; Can be omitted for `famedly`.          |
| FRC_SSH_KEY                  |                                                   | The SSH key to use                                                    |
