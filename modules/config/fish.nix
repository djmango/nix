{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      #DJMANGOFLAG

      # Initialize starship
      ${pkgs.starship}/bin/starship init fish | source

      # Add nix profile to PATH
      set -x PATH $HOME/.nix-profile/bin $PATH

      # Set up vi mode with cursors
      fish_vi_key_bindings
      set fish_cursor_default block blink
      set fish_cursor_insert line blink
      set fish_cursor_replace_one underscore blink
      set fish_cursor_visual block

      # Aliases
      alias npkg "nix search nixpkgs"
      alias gw "gh repo view -w"
      alias x "explorer"
      alias k "kubectl"

      # Source local config file if it exists (preserves your old fish config)
      if test -f ~/.config/fish/config.local.fish
        source ~/.config/fish/config.local.fish
      end

      # Load starship configuration
      set -x STARSHIP_CONFIG ${./starship.toml}
    '';

    shellInit = ''
      #DJMANGOFLAG
      # Source local env file if it exists (preserves your old fish environment)
      if test -f ~/.config/fish/env.local.fish
        source ~/.config/fish/env.local.fish
      end
    '';

    plugins = [
      # Add any fish plugins you want here
      # Example: { name = "bass"; src = pkgs.fishPlugins.bass; }
    ];
  };

  # Install required packages for fish and starship
  home.packages = with pkgs; [
    starship
    # Recommended fonts for starship
    nerd-fonts.meslo-lg
  ];
}
