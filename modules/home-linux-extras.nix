# Linux-only package additions (imported after home-base.nix).
{ pkgs, lib, ... }:

{
  home.packages = lib.mkIf pkgs.stdenv.isLinux (lib.mkAfter (with pkgs; [
    # e.g. nix-index
  ]));
}
