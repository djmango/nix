# cloudflared pinned past nixpkgs-unstable (security release, 2026.10.2 or
# later; 2026.10.3 or later on macOS when it was not installed with Homebrew).
# Systems with no pinned upstream asset in cloudflared-package.nix keep
# nixpkgs' build, so add a system there before adding it here.
final: prev:
prev.lib.optionalAttrs
  (builtins.elem prev.stdenv.hostPlatform.system [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ]) {
  cloudflared = prev.callPackage ./cloudflared-package.nix { };
}
