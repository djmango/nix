# Portable Home Manager Configuration

My minimal, portable Home Manager setup that works across macOS and Linux, for my personal dev environment.

## Module layout

```
modules/
  home-base.nix          # shared configs (nvim, fish, …) + cross-platform packages
  home-darwin.nix        # macOS-only packages (terminal-notifier, xcbeautify, …)
  home-linux-extras.nix  # Linux-only packages (optional)
  home-common.nix        # base + auto-picks darwin or linux extras (Mac/desktop)
  home-linux.nix         # base + linux extras (NixOS servers / homelab)
```

- **Mac:** `home-manager switch --flake ~/nix#default@…` uses `home-common.nix`
- **nixbox (homelab):** imports `home-linux.nix` from this flake

## One-liner

Run this command on any supported machine:

```bash
curl -L https://raw.githubusercontent.com/djmango/nix/master/setup.sh | sh
```
OR
```bash
curl -L https://nix.skg.gg | sh
```

That's it! The script will:
- Detect your username and system automatically
- Install Nix and Home Manager if missing
- Clone/pull your config repository
- Apply your Home Manager configuration
- Set up Zsh with Oh My Zsh as the default shell

### Manual Commands
```bash
# Switch to your config (after setup)
home-manager switch --impure --flake ~/nix#default@$(uname -m)-$(uname -s | tr '[:upper:]' '[:lower:]')

# Update flake dependencies
cd ~/nix && nix flake update

# Apply changes with automatic backup
home-manager switch --impure --flake ~/nix#default@$(uname -m)-$(uname -s | tr '[:upper:]' '[:lower:]') -b backup
```

## 🐛 Troubleshooting

### User Detection Issues
If the script can't detect your username:
```bash
USER=yourname curl -L https://raw.githubusercontent.com/djmango/nix/master/setup.sh | sh
```

### Package Conflicts (Linux)
If system packages conflict with Nix packages, prioritize Nix in your shell:
```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$HOME/.nix-profile/bin:$PATH"
```

### macOS GUI Applications
For GUI apps, add them to your Home Manager config:
```nix
programs.vscode.enable = true;
# or
home.packages = with pkgs; [ vscode ];
```

### Permission Issues
Ensure your user has proper permissions for Nix:
```bash
sudo chown -R $USER ~/.nix-profile
```

## 📚 Learn More

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Pills](https://nixos.org/guides/nix-pills/) - learn Nix fundamentals
- [NixOS Wiki](https://nixos.wiki/) - great resource for Nix/NixOS
