{ lib, user, ... }:
{
  networking.hostName = "nixbox";

  # GRUB boot loader for BIOS/VM setup
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  # If UEFI instead:
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK4RmXrS61fSaWojx1aK9oB1N1LzllAkOpcLrcXsUsVz djmango"
    ];
  };
}
