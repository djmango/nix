{
  description = "Nix configurations for NixOS and non-NixOS (standalone Home-Manager)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nvimcfg = { url = "github:djmango/dotfiles-nvim"; flake = false; }; # no hash dance
  };

  outputs = { self, nixpkgs, home-manager, nvimcfg, ... }:
  let
    system = "x86_64-linux";

    # Function for NixOS configurations
    mkHost = host: user:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit nvimcfg user; };  # pass to modules
        modules = [
          home-manager.nixosModules.home-manager
          ./modules/system-common.nix
          ./modules/home-common.nix
          ./hosts/${host}/hardware-configuration.nix
          ./hosts/${host}/default.nix
        ];
      };

    # Function for standalone Home-Manager configurations (non-NixOS)
    mkHome = user: homeDir:
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { inherit nvimcfg user; };  # pass to modules
        modules = [
          ./modules/home-common.nix
          {
            home.username = user;
            home.homeDirectory = homeDir;
            home.stateVersion = "24.05";
          }
        ];
      };
  in {
    # NixOS system configurations
    nixosConfigurations = {
      nixbox = mkHost "nixbox" "djmango";
      # laptop = mkHost "laptop" "djmango";
      # server = mkHost "server" "djmango";
    };

    # Standalone Home-Manager configurations for non-NixOS
    homeConfigurations = {
      djmango = mkHome "djmango" "/home/djmango";
      root = mkHome "root" "/root";  # For root user on non-NixOS
    };
  };
}
