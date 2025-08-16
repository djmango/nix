{
  description = "djmango NixOS: Neovim w/ my config, atuin, uv, zoxide, fd, cargo via rustup, SSH, wormhole";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    system   = "x86_64-linux";
    hostname = "nixbox";
    myUser   = "djmango";

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    lib = nixpkgs.lib;

    # Your Neovim config repo (pin to a commit when you can).
    nvimConfig = pkgs.fetchFromGitHub {
      owner = "djmango";
      repo  = "dotfiles-nvim";
      rev   = "master";
    };
  in {
    nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        home-manager.nixosModules.home-manager
        ({ pkgs, ... }: {
          nix.settings.experimental-features = [ "nix-command" "flakes" ];

          # Optional: create the user
          users.users.${myUser} = {
            isNormalUser = true;
            extraGroups = [ "wheel" ];
          };

          # Core CLI tools at the system level
          environment.systemPackages = with pkgs; [
            git
            openssh
          ];

          # OpenSSH server
          services.openssh = {
            enable = true;
            ports = [ 22 ];
            settings = {
              PermitRootLogin = "no";
              PasswordAuthentication = false;
              KbdInteractiveAuthentication = false;
            };
          };
          networking.firewall.allowedTCPPorts = [ 22 ];

          users.users.${myUser}.openssh.authorizedKeys.keys = [
	    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK4RmXrS61fSaWojx1aK9oB1N1LzllAkOpcLrcXsUsVz djmango"
          ];

          # Home Manager wiring
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${myUser} = { pkgs, ... }: {
            home.stateVersion = "24.05";
            programs.home-manager.enable = true;

            # Neovim (stable)
            programs.neovim = {
              enable = true;
              viAlias = true;
              vimAlias = true;
              withNodeJs = true;
              withPython3 = true;
              # package = pkgs.neovim; # default
            };

            # Put your Neovim repo into ~/.config/nvim
            xdg.configFile."nvim".source = nvimConfig;

            # Shell helpers
            programs.atuin = {
              enable = true;
              enableBashIntegration = true;
              enableZshIntegration  = true;
              enableFishIntegration = true;
            };
            programs.zoxide = {
              enable = true;
              enableBashIntegration = true;
              enableZshIntegration  = true;
              enableFishIntegration = true;
            };

            # Rust toolchain
            programs.rustup = {
              enable = true;
              defaultToolchain = "stable";
            };

            # Extra packages
            home.packages = with pkgs; [
              uv
              fd
              magic-wormhole
            ];
          };
        })
      ];
    };
  };
}

