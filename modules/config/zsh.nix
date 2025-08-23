{ pkgs, ... }:
{
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

      alias npkg="nix search nixpkgs"
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
}
