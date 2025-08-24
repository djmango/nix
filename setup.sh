#!/bin/bash

# curl -L https://raw.githubusercontent.com/djmango/nix/master/setup.sh | sh
# OR
# curl -L https://nix.skg.gg | sh

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

# Handle broken/partial Nix installs: Uninstall if /nix exists but nix not found
if [ -d /nix ] && ! command -v nix >/dev/null 2>&1; then
  echo "Detected partial Nix install; uninstalling first..."
  /nix/nix-installer uninstall --no-confirm
fi

# Install Nix if missing or after uninstall
if ! command -v nix >/dev/null 2>&1; then
  echo "Installing Nix via Determinate Systems..."
  if [ "$OS" = "darwin" ]; then
    # curl -sSL https://install.determinate.systems/nix | sh -s -- install darwin --no-confirm
    echo Try our macOS-native package instead, which can handle almost anything:
    echo https://dtr.mn/determinate-nix
  else
    USED_INIT_NONE=0
    INIT_OPT=""
    if ! command -v systemctl >/dev/null 2>&1; then
      echo "No systemd detected; using --init none for installation."
      INIT_OPT="--init none"
      USED_INIT_NONE=1
    fi
    # Use wget for minimal Linux systems (avoids curl option issues)
    if command -v wget >/dev/null 2>&1; then
      wget -q -O- https://install.determinate.systems/nix | sh -s -- install linux --no-confirm $INIT_OPT
    else
      curl -sSL https://install.determinate.systems/nix | sh -s -- install linux --no-confirm $INIT_OPT
    fi
  fi
fi

# Source profile
if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
# Explicitly set PATH (fallback for shell issues)
export PATH="/nix/var/nix/profiles/default/bin:$PATH"
# Start Nix daemon if not running and we used --init none (manual start required)
if [ "${USED_INIT_NONE:-0}" -eq 1 ] && ! ps aux | grep -q '[n]ix-daemon'; then
  echo "Starting Nix daemon manually with sudo (since no init system)..."
  sudo /nix/var/nix/profiles/default/bin/nix-daemon --daemon &
  sleep 5 # Give time for daemon to start
  if ! ps aux | grep -q '[n]ix-daemon'; then
    echo "Error: Failed to start nix-daemon. Check sudo access or logs."
    exit 1
  fi
fi
# Verify nix is available
if ! command -v nix >/dev/null 2>&1; then
  echo "Error: Nix installation failed - nix command not found after install."
  exit 1
fi

# Clone/pull repo
REPO_URL="https://github.com/djmango/nix.git"
REPO_DIR=~/nix
if [ ! -d "$REPO_DIR" ]; then
  echo "Cloning repository..."
  git clone "$REPO_URL" "$REPO_DIR"
else
  echo "Updating repository..."
  cd "$REPO_DIR"
  git pull
fi
cd "$REPO_DIR"

# Backup .zshrc if it exists and doesn't already have a local backup, and doesn't have the #DJMANGOFLAG
if [ -f ~/.zshrc ] && [ ! -f ~/.zshrc.local ] && ! grep -q "#DJMANGOFLAG" ~/.zshrc; then
  mv ~/.zshrc ~/.zshrc.local
fi
# Backup .zshenv if it exists and doesn't already have a local backup, and doesn't have the #DJMANGOFLAG
if [ -f ~/.zshenv ] && [ ! -f ~/.zshenv.local ] && ! grep -q "#DJMANGOFLAG" ~/.zshenv; then
  mv ~/.zshenv ~/.zshenv.local
fi

# Install/Apply Home Manager (bootstrap with nix run if not installed)
FLAKE_PATH="$REPO_DIR#default@${SYSTEM}"
if ! command -v home-manager >/dev/null 2>&1; then
  echo "Bootstrapping Home Manager via flake..."
  nix run github:nix-community/home-manager/release-24.05 -- switch -b backup --flake "$FLAKE_PATH" --impure
else
  echo "Applying Home Manager configuration..."
  home-manager switch -b backup --impure --flake "$FLAKE_PATH"
fi

# Change default shell to zsh if not already (requires zsh installed via Home Manager)
ZSH_PATH="$HOME/.nix-profile/bin/zsh"
if [ -x "$ZSH_PATH" ] && [ "$SHELL" != "$ZSH_PATH" ]; then
  echo "Changing default shell to zsh..."
  chsh -s "$ZSH_PATH"
  echo "Default shell changed to zsh. Log out and log back in, or run 'exec zsh' to start using it immediately."
else
  echo "Shell is already zsh or zsh not found."
fi

echo "Welcome home - skg"
