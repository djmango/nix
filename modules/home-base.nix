# Shared Home Manager config: tool configs + cross-platform packages.
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

  programs.home-manager.enable = true;
  home.enableNixpkgsReleaseCheck = false;
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

  # Safe on macOS and Linux — no platform-gated packages here.
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
    opentofu
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
    tmux
    tree
    uv
    watch
    wget
    yt-dlp
    zola
  ];
}
