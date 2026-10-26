# Pin cloudflared ahead of nixpkgs. The eMudhra intermediate CA compromise
# (https://blog.cloudflare.com/emudhra-certificate-compromise) needs cloudflared
# 2026.10.2 or later, and 2026.10.3 or later on macOS when it was not installed
# with Homebrew. nixpkgs-unstable still ships 2026.10.1.
#
# Upstream ships a bare binary for Linux and a tarball for macOS, so the install
# phase differs per platform. Each hash is the upstream sha256 for the asset
# named beside it; on a bump move `version` and every hash together.
{ lib, stdenv, fetchurl }:

let
  version = "2026.10.4";

  assets = {
    x86_64-linux = {
      file = "cloudflared-linux-amd64";
      hash = "sha256-rl6K3XiEsFMdZrvKRXDR3kkf9tpR5Ovn6xYM3yQdnkI=";
    };
    aarch64-linux = {
      file = "cloudflared-linux-arm64";
      hash = "sha256-K3IDtPsLoooMHhL4hVziwl920mao1e2vrFVAtoEqz/Y=";
    };
    aarch64-darwin = {
      file = "cloudflared-darwin-arm64.tgz";
      hash = "sha256-aLa8QICsEzAjTbKpAC0H+YsABTehvVMaaHtmDUFg+n8=";
    };
    x86_64-darwin = {
      file = "cloudflared-darwin-amd64.tgz";
      hash = "sha256-8R++9CB9cViSMxkX2v1DfwMs9LcTftZN6jAIM4wcYT0=";
    };
  };

  system = stdenv.hostPlatform.system;
  asset = assets.${system} or (throw "cloudflared: no pinned upstream asset for ${system}");
  isTarball = lib.hasSuffix ".tgz" asset.file;
in
stdenv.mkDerivation {
  pname = "cloudflared";
  inherit version;

  src = fetchurl {
    url = "https://github.com/cloudflare/cloudflared/releases/download/${version}/${asset.file}";
    inherit (asset) hash;
  };

  # The macOS tarball holds a single file at its root, so there is no
  # directory for the default source-root detection to find.
  dontUnpack = !isTarball;
  sourceRoot = ".";
  doCheck = false;

  installPhase = if isTarball then ''
    runHook preInstall
    install -Dm755 cloudflared $out/bin/cloudflared
    runHook postInstall
  '' else ''
    runHook preInstall
    install -Dm755 $src $out/bin/cloudflared
    runHook postInstall
  '';

  meta = {
    description = "Cloudflare Tunnel client";
    homepage = "https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/";
    license = lib.licenses.asl20;
    mainProgram = "cloudflared";
    platforms = builtins.attrNames assets;
  };
}
