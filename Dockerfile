# syntax=docker/dockerfile:1.4
FROM debian:latest

# Setup base system (we install weston to easily get all the Wayland deps)
RUN apt-get update && \
    apt-get install -y sudo weston mesa-vulkan-drivers openssh-client \
    git iputils-ping vulkan-tools curl iproute2 firefox-esr fonts-noto \
    xdg-utils gh rsync

# Setup non-root user with a password for added security
ARG USER=user
RUN useradd -m $USER && \
    echo passwd -d ${USER} && \
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
WORKDIR /home/${USER}
ENV HOME=/home/${USER}

# Install the fish shell for a nicer experience
RUN apt-get install -y fish
ENV SHELL=fish
RUN chsh -s /usr/bin/fish ${USER}

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies (mostly for verilator)
RUN sudo apt-get install -y \
    help2man perl python3 make autoconf g++ flex bison ccache gdb \
    libgoogle-perftools-dev numactl perl-doc \
    libfl2 libfl-dev pkg-config libssl-dev libclang-dev \
    zlib1g zlib1g-dev \
    clang clang-format \
    gtkwave cmake ninja-build \
    libspdlog-dev

# Setup tools installed into the home dir
COPY prep-home.fish /prep-home.fish
RUN chmod +x /prep-home.fish && chown ${USER} /prep-home.fish
USER ${USER}
RUN /prep-home.fish --ci

# Trunk.io simplifies automated code quality control
RUN curl https://get.trunk.io -fsSL | bash

# Install Verible for a better development experience
ARG VERIBLE_VERSION=v0.0-4051-g9fdb4057
RUN curl -L -o verible.tar.gz https://github.com/chipsalliance/verible/releases/download/${VERIBLE_VERSION}/verible-${VERIBLE_VERSION}-linux-static-x86_64.tar.gz
RUN tar -xzf verible.tar.gz
RUN sudo mv verible-${VERIBLE_VERSION}/bin/* /usr/local/bin/
RUN rm -rf verible.tar.gz verible-${VERIBLE_VERSION}

# Clone and build Verilator from source as to have the latest version
ARG VERILATOR_VERSION=v5.044
RUN git clone https://github.com/verilator/verilator.git /home/${USER}/verilator && \
    cd /home/${USER}/verilator && \
    git checkout ${VERILATOR_VERSION} && \
    autoconf && \
    ./configure && \
    make -j$(nproc) && \
    sudo make install && \
    rm -rf /home/${USER}/verilator

# Install a newer version of Node than ships with Debian
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
RUN sudo apt-get install -y nodejs

# Reset to default
ENV DEBIAN_FRONTEND=dialog

# Enter the fish shell by default
CMD ["fish", "/prep-home.fish"]
