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
    };
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
    initContent = ''
      #DJMANGOFLAG
      
      # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
      # Initialization code that may require console input (password prompts, [y/n]
      # confirmations, etc.) must go above this block; everything else may go below.
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

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

      # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    '';
    envExtra = ''
      #DJMANGOFLAG
      # Source local env file if it exists (preserves your old ~/.zshenv)
      if [ -f ~/.zshenv.local ]; then
        . ~/.zshenv.local
      fi
    '';
  };

  # Install required packages for powerlevel10k
  home.packages = with pkgs; [
    # Recommended fonts for powerlevel10k
    (nerdfonts.override { fonts = [ "MesloLGS" ]; })
  ];
}
