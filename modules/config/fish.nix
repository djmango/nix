{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Initialize starship
      ${pkgs.starship}/bin/starship init fish | source

      source '/nix/var/nix/profiles/default/etc/profile.d/nix.fish'

      fish_vi_key_bindings
      bind -M insert \t accept-autosuggestion
      
      # Aliases
      alias npkg "nix search nixpkgs"
      alias gw "gh repo view -w"
      alias x "explorer"
      alias k "kubectl"

      set -x STARSHIP_CONFIG ${./starship.toml}
    '';

    plugins = [
      { name = "bass"; src = pkgs.fishPlugins.bass; }
    ];
  };

  # Install required packages for fish and starship
  home.packages = with pkgs; [
    starship
    nerd-fonts.meslo-lg
    fishPlugins.bass
  ];
}
