#!/usr/bin/env fish

set MARKER "$HOME/.home-built"

# If the marker file already exists, exit early
if test -f "$MARKER"
    echo "Home already built; skipping."
    exec $SHELL -l
end

argparse 'ci' -- $argv
or return

echo "Building home for the first time..."

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env.fish"
fish_add_path -U "$HOME/.local/bin"

# Nextest is very useful for advanced testing
cargo install cargo-nextest --locked

# Install pnpm since it works better than npm
curl -fsSL https://get.pnpm.io/install.sh | sh -
source /home/user/.config/fish/config.fish

# We do not need to install Zed when building a base image for CI use
if not set -ql _flag_ci
    curl -f https://zed.dev/install.sh | sh
    fish_add_path -U "$HOME/.local/bin"
end

# Create the marker file to prevent re-running
touch "$MARKER"
echo "Done."

# Return to the normal shell
exec $SHELL -l
