{ pkgs, nvimcfg, ... }:
{
  # Enable Home Manager to manage itself
  programs.home-manager.enable = true;

  # Disable version mismatch warnings (we manage versions explicitly in flake.nix)
  home.enableNixpkgsReleaseCheck = false;

  # Disable Home Manager news notifications
  news.display = "silent";

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

  programs.tmux = {
    enable = true;
    prefix = "C-a";
    keyMode = "vi";
    extraConfig = ''
      # Set Ctrl+a as prefix (standard tmux default)
      set -g prefix C-a
      unbind C-b
      bind C-a send-prefix

      # Window switching
      bind -n C-h previous-window
      bind -n C-l next-window

      # Enable mouse support
      set -g mouse on

      # don't do anything when a 'bell' rings
      set -g visual-activity off
      set -g visual-bell off
      set -g visual-silence off
      setw -g monitor-activity off
      set -g bell-action none

      # clock mode
      setw -g clock-mode-colour "yellow"

      # copy mode
      setw -g mode-style "fg=black,bg=red,bold"

      # panes
      set -g pane-border-style "fg=red"
      set -g pane-active-border-style "fg=yellow"

      # statusbar
      set -g status-position bottom
      set -g status-justify left
      set -g status-style "fg=red,bg=black"

      set -g status-left ""
      set -g status-left-length 10

      set -g status-right "#[fg=black,bg=yellow] %Y-%m-%d %H:%M "
      set -g status-right-length 50

      set-option -g window-status-current-style "fg=black,bg=red"
      set-option -g window-status-current-format " #I #W #F "

      set-option -g window-status-style "fg=red,bg=black"
      set-option -g window-status-format " #I #W #F "

      set-option -g window-status-bell-style "fg=yellow,bg=red,bold"

      # messages
      set -g message-style "fg=yellow,bg=red,bold"
    '';
  };

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "rust"
        "python"
      ];
      theme = "robbyrussell";
    };
    initContent = ''
      #DJMANGOFLAG
      # start=$(gdate +%s%3N)
      export PATH="$HOME/.nix-profile/bin:$PATH"
      eval "$(atuin init zsh)"
      eval "$(direnv hook zsh)"
      eval "$(zoxide init --cmd cd zsh)"

      alias gw="gh repo view -w"
      alias x="explorer"
      alias k="kubectl"

      # Source local rc file if it exists (preserves your old ~/.zshrc)
      if [ -f ~/.zshrc.local ]; then
        . ~/.zshrc.local
      fi

      # end=$(gdate +%s%3N)
      # echo "Shell load time: $((end-start))ms"
    '';
    envExtra = ''
      #DJMANGOFLAG
      # Source local env file if it exists (preserves your old ~/.zshenv)
      if [ -f ~/.zshenv.local ]; then
        . ~/.zshenv.local
      fi
    '';
  };
  home.packages = with pkgs; [
    bun
    cargo
    clippy
    code2prompt
    fd
    gh
    git
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
