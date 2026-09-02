# Desktop Ollama: official binary + user service (launchd on macOS).
# nixpkgs in this flake is still 0.32.7; upstream (and the Homebrew cask) is 0.33.2.
{ pkgs, lib, ... }:
let
  ollamaVersion = "0.33.2";
  ollamaOfficial = pkgs.stdenvNoCC.mkDerivation {
    pname = "ollama";
    version = ollamaVersion;
    src = pkgs.fetchurl {
      url = "https://github.com/ollama/ollama/releases/download/v${ollamaVersion}/ollama-darwin.tgz";
      hash = "sha256-V1HilqLNVFk5vdUbcA3gwg0xnw5yPJ1/SL67WrC3MdQ=";
    };
    sourceRoot = ".";
    dontStrip = true;
    dontFixup = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin $out/lib/ollama
      install -m755 ollama $out/bin/ollama
      rm -f ollama
      mv -- * $out/lib/ollama/
      runHook postInstall
    '';
    meta = {
      mainProgram = "ollama";
      description = "Get up and running with large language models locally";
      homepage = "https://ollama.com";
    };
  };
in
{
  services.ollama = {
    enable = pkgs.stdenv.isDarwin;
    package = lib.mkIf pkgs.stdenv.isDarwin ollamaOfficial;
  };
}
