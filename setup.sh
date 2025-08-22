#!/bin/bash
set -e



# Detect system and arch (e.g., x86_64-darwin or aarch64-linux)
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
if [ "$OS" = "darwin" ]; then
  # Map arm64 to aarch64 for Darwin systems
  if [ "$ARCH" = "arm64" ]; then
    ARCH="aarch64"
  fi
  SYSTEM="${ARCH}-darwin"
elif [ "$OS" = "linux" ]; then
  SYSTEM="${ARCH}-linux"
else
  echo "Error: Unsupported OS: $OS"
  exit 1
fi

echo "Detected system: $SYSTEM"

# Install Nix if missing
if ! command -v nix >/dev/null 2>&1; then
  echo "Installing Nix..."
  curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
  . ~/.nix-profile/etc/profile.d/nix.sh
fi

# Enable flakes if not already
mkdir -p ~/.config/nix
if ! grep -q "experimental-features" ~/.config/nix/nix.conf 2>/dev/null; then
  echo "Enabling Nix flakes..."
  echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
fi

# Install Home Manager if missing (standalone mode)
if ! command -v home-manager >/dev/null 2>&1; then
  echo "Installing Home Manager..."
  nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
  nix-channel --update
  nix-shell '<home-manager>' -A install
fi

# Clone/pull repo (assuming GitHub repo; adjust if using different git hosting)
REPO_URL="https://github.com/djmango/nix.git"
REPO_DIR=~/nix-config
if [ ! -d "$REPO_DIR" ]; then
  echo "Cloning repository..."
  git clone "$REPO_URL" "$REPO_DIR"
else
  echo "Updating repository..."
  cd "$REPO_DIR"
  git pull
fi
cd "$REPO_DIR"

# Apply config (with --impure to allow dynamic env var detection)
echo "Applying Home Manager configuration..."
home-manager switch --impure --flake .#default@${SYSTEM}

echo "Setup complete! Your Home Manager environment is ready."
echo "You can now use commands like: uv, fd, magic-wormhole, etc."
echo "Your Neovim config is available at ~/.config/nvim"
