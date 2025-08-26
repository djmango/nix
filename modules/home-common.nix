{ pkgs, ... }:
{
  imports = [
    ./config/atuin.nix
    ./config/neovim.nix
    ./config/starship.nix
    ./config/tmux.nix
    ./config/zoxide.nix
    ./config/fish.nix
  ];

  # Enable Home Manager to manage itself
  programs.home-manager.enable = true;

  # Disable version mismatch warnings (we manage versions explicitly in flake.nix)
  home.enableNixpkgsReleaseCheck = false;

  # Disable Home Manager news notifications
  news.display = "silent";

  programs.direnv.enable = true;

  programs.bash = {
    initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  # Core programs
  home.packages = with pkgs; [
    bat
    bun
    code2prompt
    dotslash
    eza
    fd
    ffmpeg
    gh
    git
    git-lfs
    htop
    jq
    magic-wormhole
    nil
    nixd
    nixfmt
    rclone
    rsync
    ruff
    rustup
    tmux
    uv
    zed-editor
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Optional: Platform-specific packages (add if needed)
  # home.packages = with pkgs; home.packages ++ (if stdenv.isDarwin then [ /* macOS-only */ ] else [ /* Linux-only */ ]);
}
