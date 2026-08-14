{
  description = "Portable Home Manager config for packages and user settings";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    # Supported systems (add more if needed, e.g., aarch64-linux for ARM Linux)
    systems = [
      "x86_64-linux"   # Intel/AMD Linux
      "aarch64-linux"  # ARM Linux (e.g., Raspberry Pi)
      "x86_64-darwin"  # Intel macOS
      "aarch64-darwin" # Apple Silicon macOS
    ];

    # nixpkgs is still on 1.3.13. The 1.3.14 bump (NixOS/nixpkgs#519796) is
    # held as a draft over a NixOS `bun build --compile` ELF regression;
    # omp.sh and similar installers require 1.3.14+.
    bunOverlay = final: prev:
      let
        version = "1.3.14";
        sources = {
          aarch64-darwin = prev.fetchurl {
            url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-darwin-aarch64.zip";
            hash = "sha256-2LliIYKK1vl6x6wKt+lYcjQa92MAHogD6CZ2UsJlJiA=";
          };
          aarch64-linux = prev.fetchurl {
            url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-aarch64.zip";
            hash = "sha256-on/7Y6gxA3WDbg1vZorhf6jY0YuIw3yCHGUzGXOhmjs=";
          };
          x86_64-darwin = prev.fetchurl {
            url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-darwin-x64-baseline.zip";
            hash = "sha256-PjWtb1OXGpg0v55nhuKt9ytfGSHMmpxf3gc9KXKUQHY=";
          };
          x86_64-linux = prev.fetchurl {
            url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64.zip";
            hash = "sha256-lR7iruhV8IWVruxiJSJqKY0/6oOj3NZGXAnLzN9+hI8=";
          };
        };
      in {
        bun = prev.bun.overrideAttrs (_old: {
          inherit version;
          src = sources.${prev.stdenv.hostPlatform.system}
            or (throw "Unsupported system: ${prev.stdenv.hostPlatform.system}");
        });
      };

    # Function to create a Home Manager config for a given system
    mkHome = system:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ bunOverlay ];
        };
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

    # Reusable per-project dev shells (e.g. for the robotics/C++ build deps that
    # were removed from the global Homebrew/Nix profile). Use with:
    #   nix flake init -t ~/nix#cpp   (scaffold a project flake)
    #   nix develop ~/nix#cpp         (drop straight into the shell)
    templates.cpp = {
      path = ./templates/cpp;
      description = "C++/robotics/CV dev shell (cmake, ninja, eigen, boost, Qt, ...)";
    };

    devShells = builtins.listToAttrs (map (system: {
      name = system;
      value.cpp = import ./templates/cpp/shell.nix nixpkgs.legacyPackages.${system};
    }) systems);
  };
}
