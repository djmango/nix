# Thin wrapper so Home Manager can import the module that lives in the omp repo.
# Do not reference `config` here — `imports` cannot depend on module config
# (that is an infinite recursion). HOME is already required by this flake
# (`--impure` + builtins.getEnv).
{ lib, ... }:

let
  homeDir = builtins.getEnv "HOME";
  ompHome = "${homeDir}/GitHub/omp/nix/home.nix";
in {
  imports = lib.optional (homeDir != "" && builtins.pathExists ompHome) ompHome;
}
