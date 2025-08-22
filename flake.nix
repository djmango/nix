{
  description = "Portable Home Manager config for packages and user settings";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nvimcfg = { url = "github:djmango/dotfiles-nvim"; flake = false; };
  };

  outputs = { self, nixpkgs, home-manager, nvimcfg, ... }@inputs:
  let
    # Supported systems (add more if needed, e.g., aarch64-linux for ARM Linux)
    systems = [
      "x86_64-linux"   # Intel/AMD Linux
      "aarch64-linux"  # ARM Linux (e.g., Raspberry Pi)
      "x86_64-darwin"  # Intel macOS
      "aarch64-darwin" # Apple Silicon macOS
    ];

    # Function to create a Home Manager config for a given system
    mkHome = system:
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { inherit nvimcfg; };  # Pass nvimcfg if needed in modules
        modules = [
          ./modules/home-common.nix
          ({ pkgs, config, ... }: {
            # Dynamically set username and home dir (requires --impure)
            home.username = let
              username = builtins.getEnv "USER";
            in if username != "" then username else throw "Username could not be determined: Set $USER environment variable or define home.username explicitly in your config.";

            home.homeDirectory = let
              homeDir = builtins.getEnv "HOME";
            in if homeDir != "" then homeDir else (
              if pkgs.stdenv.isDarwin then "/Users/${config.home.username}" else "/home/${config.home.username}"
            );

            home.stateVersion = "24.05";
          })
        ];
      };
  in {
    # Output configs for each system
    homeConfigurations = builtins.listToAttrs (map (system: {
      name = "default@${system}";
      value = mkHome system;
    }) systems);
  };
}
