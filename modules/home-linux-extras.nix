# Linux-only package additions (imported after home-base.nix).
{ pkgs, lib, ... }:

{
  home.packages = lib.mkAfter (with pkgs; [
    # e.g. nix-index
  ]);
}
