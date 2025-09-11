{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      source '/nix/var/nix/profiles/default/etc/profile.d/nix.fish'

      ${pkgs.starship}/bin/starship init fish | source
      
      set fish_greeting "Welcome home, $USER"
      
      # Source fish.local if it exists
      if test -f ~/.config/fish/fish.local
        source ~/.config/fish/fish.local
      end
      
      # On darwin, and if homebrew is installed, setup homebrew path
      if test (uname) = "Darwin"
        if test -d /opt/homebrew/bin
          eval "$(/opt/homebrew/bin/brew shellenv)"
        end
      end
      
      set -gx PATH $HOME/.cargo/bin $PATH

      fish_vi_key_bindings
      bind -M insert \t accept-autosuggestion or complete
      bind -M insert \el accept-autosuggestion
      bind -M insert \e\; complete
      bind \cx\ce edit_command_buffer
      bind -M insert \cx\ce edit_command_buffer
      bind -M default \cx\ce edit_command_buffer
      
      alias npkg "nix search nixpkgs"
      alias gw "gh repo view -w"
      alias x "explorer"
      alias k "kubectl"
      alias ls "eza"
    '';

    plugins = [
      { name = "bass"; src = pkgs.fishPlugins.bass; }
    ];
  };

  # Install required packages for fish
  home.packages = with pkgs; [
    nerd-fonts.meslo-lg
    fishPlugins.bass
  ];
}
