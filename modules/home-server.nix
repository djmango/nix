# Home Manager profile for NixOS servers (nixbox, karakeep, …).
{ pkgs, lib, ... }:

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

  home.packages = with pkgs; [
    age
    bat
    broot
    bun
    code2prompt
    docker-compose
    duckdb
    dust
    eza
    fd
    ffmpeg
    fswatch
    fx
    gawk
    gh
    git
    git-lfs
    gnused
    go
    graphviz
    helix
    htop
    imagemagick
    jq
    lsof
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

  nixpkgs.config.allowUnfree = true;
}
