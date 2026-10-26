# cloudflared pinned past nixpkgs-unstable (security release, 2026.10.2 or later).
# Linux x86_64 only: other systems keep nixpkgs' build.
final: prev:
prev.lib.optionalAttrs (prev.stdenv.hostPlatform.system == "x86_64-linux") {
  cloudflared = prev.callPackage ./cloudflared-package.nix { };
}
