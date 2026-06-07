{ pkgs, ... }:
{
  imports = [
    ./config/atuin.nix
    ./config/neovim.nix
    ./config/starship.nix
    ./config/tmux.nix
    ./config/zoxide.nix
    ./config/fish.nix
    ./config/package-managers.nix
  ];

  # Enable Home Manager to manage itself
  programs.home-manager.enable = true;

  # Disable version mismatch warnings (we manage versions explicitly in flake.nix)
  home.enableNixpkgsReleaseCheck = false;

  # Disable Home Manager news notifications
  news.display = "silent";

  programs.direnv.enable = true;

  programs.fzf.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.sessionPath = [
    "${pkgs.nodejs_24}/bin"
  ];

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
    age
    arduino-cli
    bat
    broot
    bun
    ccls
    code2prompt
    docker-compose
    dotslash
    duckdb
    dust
    efm-langserver
    eza
    exiftool
    fd
    ffmpeg
    fswatch
    fx
    gawk
    gh
    ghostscript
    git
    git-lfs
    gnused
    go
    graphviz
    helix
    htop
    iamb
    imagemagick
    jq
    lsof
    luarocks
    magic-wormhole
    mpv
    nmap
    nodejs_24
    nil
    nixd
    nixfmt
    parallel
    poppler-utils
    rclone
    ripgrep
    rsync
    ruby_3_3
    ruff
    rustup
    s5cmd
    sops
    swiftformat
    terminal-notifier
    tmux
    tree
    uv
    watch
    wget
    xcbeautify
    yt-dlp
    zola
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Optional: Platform-specific packages (add if needed)
  # home.packages = with pkgs; home.packages ++ (if stdenv.isDarwin then [ /* macOS-only */ ] else [ /* Linux-only */ ]);
}
