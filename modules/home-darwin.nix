# macOS-only package additions (imported after home-base.nix).
{ pkgs, lib, ... }:

{
  imports = [
    ./config/sidepulse.nix
  ];

  home.packages = lib.mkIf pkgs.stdenv.isDarwin (lib.mkAfter (with pkgs; [
    swiftformat
    terminal-notifier
    xcbeautify
  ]));

  # Enable the SidePulse LED status mirror on this Mac (no-op on Linux hosts;
  # the module itself gates on `pkgs.stdenv.isDarwin`).
  sidepulse.enable = true;
}
