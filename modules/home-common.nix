{ pkgs, nvimcfg, ... }:
{
  # Enable Home Manager to manage itself
  programs.home-manager.enable = true;

  # Disable version mismatch warnings (we manage versions explicitly in flake.nix)
  home.enableNixpkgsReleaseCheck = false;

  # Core programs and configs
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
  };
  xdg.configFile."nvim".source = nvimcfg;

  programs.atuin.enable = true;
  programs.zoxide.enable = true;

  # programs.git = {
  #   enable = true;
  #   userName = "Your Name";
  #   userEmail = "your.email@example.com";
  # };

  # Note: Cargo is installed as a package, no additional configuration needed

  # Custom packages
  home.packages = with pkgs; [
    uv # Fast Python package manager
    ruff # Fast Python linter and formatter
    fd # Fast file finder
    rustc # Rust compiler
    cargo # Rust package manager
    rust-analyzer # Rust language server
    clippy # Rust linter
    git
    gh
    rclone
    htop # System monitor
    magic-wormhole # Secure file transfer
    nil # Nix language server
    nixd
    code2prompt # Convert codebases to prompts for AI
    zed-editor # Zed code editor
    bun
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Optional: Platform-specific packages (add if needed)
  # home.packages = with pkgs; home.packages ++ (if stdenv.isDarwin then [ /* macOS-only */ ] else [ /* Linux-only */ ]);

  # Add more program configs here, e.g.:
  # programs.zsh = { enable = true; /* aliases, etc. */ };

}
