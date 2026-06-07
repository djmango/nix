{
  description = "C++/robotics/CV dev shell (cmake, ninja, eigen, boost, Qt, ...)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
  let
    systems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];
    forAll = f: builtins.listToAttrs (map (system: {
      name = system;
      value = f nixpkgs.legacyPackages.${system};
    }) systems);
  in {
    devShells = forAll (pkgs: {
      default = import ./shell.nix pkgs;
    });
  };
}
