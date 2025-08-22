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

  # Packages (add/edit here; these are user-installed and portable)
  home.packages = with pkgs; [
    uv
    fd
    magic-wormhole
    rustc
    cargo
    rust-analyzer
    clippy
    # Example additions: git htop (uncomment/add as needed)
    # git
    # htop
  ];

  # Allow unfree packages (e.g., for VS Code if you add it later)
  nixpkgs.config.allowUnfree = true;

  # Optional: Platform-specific packages (add if needed)
  # home.packages = with pkgs; home.packages ++ (if stdenv.isDarwin then [ /* macOS-only */ ] else [ /* Linux-only */ ]);

  # Add more program configs here, e.g.:
  # programs.zsh = { enable = true; /* aliases, etc. */ };
}
