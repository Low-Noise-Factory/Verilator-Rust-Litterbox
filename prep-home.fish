#!/usr/bin/env fish

argparse 'ci' -- $argv
or return

echo "Building home for the first time..."

# We use osv-scanner to scan for vulnerabilities
wget https://github.com/google/osv-scanner/releases/download/v2.5.0/osv-scanner_linux_amd64
chmod +x osv-scanner_linux_amd64
mkdir -p "$HOME/.local/bin"
mv osv-scanner_linux_amd64 "$HOME/.local/bin/osv-scanner"
fish_add_path -U "$HOME/.local/bin"
echo "Installed osv-scanner!"

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env.fish"

# Nextest is very useful for advanced testing
cargo install cargo-nextest --locked

# We use flip-link to make our fimrware more robust
cargo install flip-link --locked

# We use probe-rs to flash MCU firmware and debug
cargo install probe-rs-tools --locked --features remote

# We use binutils to creat update binaries
cargo install cargo-binutils --locked

# We use cyclonedx to generate SBOM files
cargo install cargo-cyclonedx --locked

# We use pnpm since it works better than npm
curl -fsSL https://get.pnpm.io/install.sh | sh -
source /home/user/.config/fish/config.fish

# We do not need to install Zed when building a base image for CI use
if not set -ql _flag_ci
    curl -f https://zed.dev/install.sh | sh
end
