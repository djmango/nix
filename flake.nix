{
  description = "NixOS: shared modules + per-host hardware (pure)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nvimcfg = { url = "github:djmango/dotfiles-nvim"; flake = false; }; # no hash dance
  };

  outputs = { self, nixpkgs, home-manager, nvimcfg, ... }:
  let
    system = "x86_64-linux";
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
  in {
    # Define one entry per machine
    nixosConfigurations = {
      nixbox = mkHost "nixbox" "djmango";
      # laptop = mkHost "laptop" "djmango";
      # server = mkHost "server" "djmango";
    };
  };
}
