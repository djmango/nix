# Tailscale CLI from nixpkgs.
#
# The daemon is system-level (NixOS `services.tailscale`, or Tailscale.app on
# macOS). This only puts `tailscale` on PATH.
#
# Default: on for Linux, off for macOS (install the official .app there).
# Opt in on a Mac with:
#   tailscale.enable = true;
{ config, pkgs, lib, ... }:

{
  options.tailscale.enable = lib.mkOption {
    type = lib.types.bool;
    default = pkgs.stdenv.isLinux;
    defaultText = lib.literalExpression "pkgs.stdenv.isLinux";
    description = ''
      Install the Tailscale CLI from nixpkgs.
      On by default on Linux. Off by default on macOS, where the official
      Tailscale.app is the usual install.
    '';
  };

  config = lib.mkIf config.tailscale.enable {
    home.packages = [ pkgs.tailscale ];
  };
}
