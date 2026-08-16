# Optional macOS-only module: SidePulse LED status mirror.
#
# Drives a SidePulse Pro / Dot from agent status events (Cursor, omp) via a
# small headless daemon + launchd agent. The `sidepulse` CLI itself is kept on
# `uv tool` (packaging pyobjc in nix is heavy); this module declaratively
# manages the daemon/bridge scripts and the LaunchAgent instead.
#
# Enable on a host with:
#   sidepulse.enable = true;   # macOS only; ignored on Linux.
{ config, pkgs, lib, ... }:

let
  cfg = config.sidepulse;

  # The `sidepulse` CLI is installed via `uv tool` into the user's profile.
  uvSidepulsePython =
    "${config.home.homeDirectory}/.local/share/uv/tools/sidepulse/bin/python";

  stateDir = "${config.home.homeDirectory}/.local/state/sidepulse/agent-monitor";
in
{
  options.sidepulse = {
    enable = lib.mkEnableOption "the SidePulse LED status mirror (macOS)";
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
    home.file.".local/bin/sidepulse-led-mirror" = {
      source = ./sidepulse/sidepulse-led-mirror;
      executable = true;
      # The repo copy is the source of truth; replace legacy plain files.
      force = true;
    };
    home.file.".local/bin/sidepulse-cursor-status" = {
      source = ./sidepulse/sidepulse-cursor-status;
      executable = true;
      force = true;
    };

    launchd.agents.sidepulse-ledmirror = {
      enable = true;
      config = {
        RunAtLoad = true;
        KeepAlive = true;
        ThrottleInterval = 10;
        ProgramArguments = [
          uvSidepulsePython
          "${config.home.homeDirectory}/.local/bin/sidepulse-led-mirror"
        ];
        StandardOutPath = "${stateDir}/led-mirror.log";
        StandardErrorPath = "${stateDir}/led-mirror.err.log";
        EnvironmentVariables = {
          HOME = config.home.homeDirectory;
          PATH = "/usr/bin:/bin:/usr/sbin:/sbin:${config.home.homeDirectory}/.local/bin:/opt/homebrew/bin";
        };
      };
    };
  };
}
