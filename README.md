# Verilator-Rust-Litterbox

This is a [Litterbox](https://github.com/Gerharddc/litterbox) image that provides both the Rust and the Verilator toolchain. This image is suitable both for building inside a CI environment and as a local development environment.

## Usage

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
