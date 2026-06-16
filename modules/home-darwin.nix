# macOS-only package additions (imported after home-base.nix).
{ pkgs, lib, ... }:

{
  home.packages = lib.mkAfter (with pkgs; [
    swiftformat
    terminal-notifier
    xcbeautify
  ]);
}
