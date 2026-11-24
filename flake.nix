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

    # The galatea tree declares bun 1.4.2 (package.json `packageManager` +
    # `engines.bun`) and 13 of its 27 committed lockfiles are `lockfileVersion:
    # 2`, which a 1.3 bun cannot parse at all ("Unknown lockfile version", then
    # "lockfile had changes, but lockfile is frozen"). nixpkgs lags at 1.3.13
    # (the 1.3.14 bump, NixOS/nixpkgs#519796, is held as a draft over a NixOS
    # `bun build --compile` ELF regression), so pin the release the tree asks
    # for here. The hold at 1.3.14 existed because omp.sh and similar installers
    # require 1.3.14+, which 1.4.2 satisfies too.
    bunOverlay = final: prev:
      let
        version = "1.4.2";
        sources = {
          aarch64-darwin = prev.fetchurl {
            url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-darwin-aarch64.zip";
            hash = "sha256-kJh6OhbX21VtiGrD1VHnttPt8KHPQ6yu1iLoZ2vh0S8=";
          };
          aarch64-linux = prev.fetchurl {
            url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-aarch64.zip";
            hash = "sha256-VDKLvC2cjgyfiSxUTWbFeoO4QTnjSQnl7oF1jxrI/ac=";
          };
          x86_64-darwin = prev.fetchurl {
            url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-darwin-x64-baseline.zip";
            hash = "sha256-utW71s8U0JgNEV9ZVMn/kE32GdXplNLaH/zNPzFjALA=";
          };
          x86_64-linux = prev.fetchurl {
            url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64.zip";
            hash = "sha256-NjaPrvdSeHXV/6UuU81IAhdB8qg+tiCKjdZAaNQiqRM=";
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
          overlays = [ bunOverlay (import ./overlays/cloudflared.nix) (import ./overlays/btop.nix) ];
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
    # Output configs for each system.
    # Darwin's `uname -m` is `arm64`; Nix's canonical system is `aarch64-darwin`.
    # Alias the uname spelling so `~/nix#default@$(uname -m)-darwin` works.
    homeConfigurations =
      let
        homes = builtins.listToAttrs (map (system: {
          name = "default@${system}";
          value = mkHome system;
        }) systems);
      in homes // {
        "default@arm64-darwin" = homes."default@aarch64-darwin";
      };

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
