{ lib, pkgs, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  # Set once per system lineage; don't bump casually.
  system.stateVersion = "24.05";

  environment.systemPackages = with pkgs; [
    git
    openssh
    htop
    zerotierone
  ];

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
  services.zerotierone.enable = true;
}
