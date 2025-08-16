{ lib, user, ... }:
{
  networking.hostName = "nixbox";

  # Pick one boot loader; adjust per machine as needed.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # If BIOS instead:
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/sda";

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK4RmXrS61fSaWojx1aK9oB1N1LzllAkOpcLrcXsUsVz djmango"
    ];
  };
}
