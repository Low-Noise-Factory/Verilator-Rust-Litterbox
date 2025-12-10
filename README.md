# Verilator-Rust-Litterbox

This is a [Litterbox](https://github.com/Gerharddc/litterbox) image that provides both the Rust and the Verilator toolchain. This image is suitable both for building inside a CI environment and as a local development environment.

## Usage

### In Litterbox

To use this as the base image for your Litterbox, you can use the following Dockerfile:

```
FROM ghcr.io/low-noise-factory/verilator-rust-litterbox:main

ARG USER
ARG PASSWORD

# Switch to root for sensitive files
USER root

# Setup non-root user with a password for added security
RUN usermod -l $USER user -m -d /home/$USER && \
    echo "${USER}:${PASSWORD}" | chpasswd && \
    echo "${USER} ALL=(ALL) ALL" > /etc/sudoers
RUN chown $USER /prep-home.fish

# Setup the correct environment for the user
WORKDIR /home/$USER
ENV HOME=/home/${USER}

# Switch back to less privileged user
USER ${USER}
```

### In GitHub actions

To use this as an image to run CI/CD jobs in, you can adapt the following to your needs:

```
name: Build and Test

on: [push]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/low-noise-factory/verilator-rust-litterbox:main
      options: --user root

    steps:
      # Github runners have a very random home directory by default
      - name: Preserve $HOME set in the container
        run: echo HOME=/home/user >> "$GITHUB_ENV"

      # Running as root makes git unhappy without this
      - name: Configure Git safe directory
        run: git config --global --add safe.directory '*'

      - name: Checkout repository
        uses: actions/checkout@v6

      - name: Build and Test
        run: ./build-and-test.fish
```

## Contributing

This image is purely intended for internal use at LNF. Please feel free to use it if you find it useful. However, no support will be provided for external users.
