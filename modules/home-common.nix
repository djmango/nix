{ pkgs, ... }:
{
  imports = [
    ./config/atuin.nix
    ./config/neovim.nix
    ./config/tmux.nix
    ./config/zoxide.nix
    ./config/zsh.nix
  ];

  # Enable Home Manager to manage itself
  programs.home-manager.enable = true;

  # Disable version mismatch warnings (we manage versions explicitly in flake.nix)
  home.enableNixpkgsReleaseCheck = false;

  # Disable Home Manager news notifications
  news.display = "silent";

  programs.direnv.enable = true;

  # Core programs
  home.packages = with pkgs; [
    bun
    cargo
    clippy
    code2prompt
    dotslash
    fd
    gh
    git
    git-lfs
    htop
    magic-wormhole
    nil
    nixd
    nixfmt
    rclone
    ruff
    rust-analyzer
    rustc
    tmux
    uv
    zed-editor
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Optional: Platform-specific packages (add if needed)
  # home.packages = with pkgs; home.packages ++ (if stdenv.isDarwin then [ /* macOS-only */ ] else [ /* Linux-only */ ]);
}
