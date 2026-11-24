# btop that finds the host's NVIDIA driver on Linux (see btop-package.nix), so
# the one btop in home-base.nix works on GPU hosts too. macOS keeps nixpkgs'
# btop unchanged.
final: prev:
prev.lib.optionalAttrs prev.stdenv.hostPlatform.isLinux {
  btop = prev.callPackage ./btop-package.nix { btop = prev.btop; };
}
