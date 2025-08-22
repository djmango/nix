# Portable Home Manager Configuration

A minimal, portable Home Manager setup that works across macOS and Linux (NixOS or non-NixOS) without hardcoding usernames, paths, or platform-specific configurations.

## One-liner

Run this command on any supported machine:

```bash
curl -L https://raw.githubusercontent.com/djmango/nix/master/setup.sh | sh
```

That's it! The script will:
- Detect your username and system automatically
- Install Nix and Home Manager if missing
- Clone/pull your config repository
- Apply your Home Manager configuration

## 📁 Repository Structure

```
nix/
├── flake.nix                 # Home Manager configuration definitions
├── flake.lock                # Locked dependencies
├── setup.sh                  # One-line installation script
└── modules/
    └── home-common.nix       # Your main config—add packages here
```

### Adding Packages

Edit `modules/home-common.nix` and add to the `home.packages` list:

```nix
home.packages = with pkgs; [
  # Your existing packages...
  git
  htop
  python3
  nodejs
  # Add more here
];
```

### Adding Program Configurations

Add more program configs in `modules/home-common.nix`:

```nix
programs.zsh = {
  enable = true;
  initExtra = ''
    # Your zsh config
  '';
};

programs.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "your.email@example.com";
};
```

### Platform-Specific Packages

For packages that only work on specific platforms:

```nix
home.packages = with pkgs; [
  # Common packages...
] ++ (if stdenv.isDarwin then [
  # macOS-only packages
] else [
  # Linux-only packages
]);
```

## 🔄 Usage

### First-Time Setup
```bash
curl -L https://raw.githubusercontent.com/djmango/nix/master/setup.sh | sh
```

### Update Configuration
1. Edit `modules/home-common.nix`
2. Commit and push changes
3. Run the setup command again on any machine

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

## 🔒 Security Notes

- No hardcoded usernames or SSH keys
- No system-level configurations
- Safe to run on shared systems
- All packages installed to user profile only

## 📚 Learn More

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Pills](https://nixos.org/guides/nix-pills/) - learn Nix fundamentals
- [NixOS Wiki](https://nixos.wiki/) - great resource for Nix/NixOS
