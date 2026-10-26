# Pin cloudflared ahead of nixpkgs. 2026.10.2 or later is required (security
# release) and nixpkgs-unstable lagged at 2026.10.1 when this was written.
# Hash is the upstream sha256 for cloudflared-linux-amd64 in the release notes.
# On a bump, move `version` and `hash` together.
{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "cloudflared";
  version = "2026.10.4";

  src = fetchurl {
    url = "https://github.com/cloudflare/cloudflared/releases/download/${version}/cloudflared-linux-amd64";
    hash = "sha256-rl6K3XiEsFMdZrvKRXDR3kkf9tpR5Ovn6xYM3yQdnkI=";
  };

  dontUnpack = true;
  doCheck = false;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/cloudflared
    runHook postInstall
  '';

  meta = {
    description = "Cloudflare Tunnel client";
    homepage = "https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/";
    license = lib.licenses.asl20;
    mainProgram = "cloudflared";
    platforms = [ "x86_64-linux" ];
  };
}
