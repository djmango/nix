# Thin wrapper so Home Manager can import the module that lives in the omp repo.
{ config, lib, ... }:

let
  ompHome = "${config.home.homeDirectory}/GitHub/omp/nix/home.nix";
in {
  imports = lib.optional (builtins.pathExists ompHome) ompHome;
}
