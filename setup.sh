#!/bin/bash

# curl -L https://raw.githubusercontent.com/djmango/nix/master/setup.sh | sh
# OR
# curl -L https://nix.skg.gg | sh

set -e

# Check if running as root
IS_ROOT=false
if [ "$(id -u)" -eq 0 ]; then
  IS_ROOT=true
fi

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
  /nix/nix-installer uninstall
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

    # Better systemd detection: check if systemctl exists AND systemd is active
    if command -v systemctl >/dev/null 2>&1; then
      # systemctl exists, now check if systemd is actually running
      if systemctl is-system-running >/dev/null 2>&1; then
        echo "systemd detected and active; using standard installation."
      else
        echo "systemctl found but systemd not active; using --init none for installation."
        INIT_OPT="--init none"
        USED_INIT_NONE=1
      fi
    else
      echo "No systemctl command found; using --init none for installation."
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
  if [ "$IS_ROOT" = true ]; then
    echo "Starting Nix daemon manually (running as root, no sudo needed)..."
    /nix/var/nix/profiles/default/bin/nix-daemon --daemon &
  else
    echo "Starting Nix daemon manually with sudo (since no init system)..."
    sudo /nix/var/nix/profiles/default/bin/nix-daemon --daemon &
  fi
  sleep 5 # Give time for daemon to start
  if ! ps aux | grep -q '[n]ix-daemon'; then
    if [ "$IS_ROOT" = true ]; then
      echo "Error: Failed to start nix-daemon. Check logs."
    else
      echo "Error: Failed to start nix-daemon. Check sudo access or logs."
    fi
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

# Install/Apply Home Manager (bootstrap with nix run if not installed)
FLAKE_PATH="$REPO_DIR#default@${SYSTEM}"
if ! command -v home-manager >/dev/null 2>&1; then
  echo "Bootstrapping Home Manager via flake..."
  nix run github:nix-community/home-manager/release-24.05 -- switch -b backup --flake "$FLAKE_PATH" --impure
else
  echo "Applying Home Manager configuration..."
  home-manager switch -b backup --impure --flake "$FLAKE_PATH"
fi

# Change default shell to fish if not already
FISH_PATH="$HOME/.nix-profile/bin/fish"
if [ -x "$FISH_PATH" ]; then
  if [ "$SHELL" = "$FISH_PATH" ]; then
    echo "Shell is already set to fish."
  else
    # Check if fish is in /etc/shells, add it if not
    if ! grep -q "^$FISH_PATH$" /etc/shells 2>/dev/null; then
      echo "Adding fish to /etc/shells..."
      if [ "$IS_ROOT" = true ]; then
        echo "$FISH_PATH" >> /etc/shells
      else
        echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
      fi
    fi

    # Only ask for confirmation if we actually need to switch shells
    echo "Current shell: $SHELL"
    echo "Fish shell available at: $FISH_PATH"

    # Check if we're in an interactive terminal
    if [ -t 0 ]; then
      echo "Would you like to change your default shell to fish? (y/N)"
      read -r response
      case "$response" in
        [yY][eE][sS]|[yY])
          echo "Changing default shell to fish..."
          ;;
        *)
          echo "Keeping current shell ($SHELL). You can manually change it later with 'chsh -s $FISH_PATH'"
          exit 0
          ;;
      esac
    else
      echo "Non-interactive environment detected. Skipping shell change prompt."
      echo "You can manually change your shell later with: chsh -s $FISH_PATH"
      exit 0
    fi

    if [ "$IS_ROOT" = true ]; then
      if chsh -s "$FISH_PATH" || [ "$SHELL" = "$FISH_PATH" ]; then
        echo "Default shell changed to fish. Log out and log back in to start using it immediately."
      else
        echo "Error: Failed to change shell to fish."
      fi
    else
      if sudo chsh -s "$FISH_PATH" || [ "$SHELL" = "$FISH_PATH" ]; then
        echo "Default shell changed to fish. Log out and log back in to start using it immediately."
      else
        echo "Error: Failed to change shell to fish. You may need to enter your password or check permissions."
      fi
    fi
  fi
else
  echo "Fish shell not found at $FISH_PATH. Make sure Home Manager has installed fish."
fi

echo "Welcome home - skg"
