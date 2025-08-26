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
      
      alias npkg "nix search nixpkgs"
      alias gw "gh repo view -w"
      alias x "explorer"
      alias k "kubectl"
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
