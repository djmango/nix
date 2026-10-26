# gws behind a gate: the binary on PATH is a wrapper, and the wrapper hands
# every call to a gate script that this machine supplies.
#
# Why: on a machine that runs an agent, `gws` reads mail and must never write or
# send it. The rule for what a call may do lives in the gate script, not here:
# this repo is shared and public, so it carries no policy text, only the wiring.
# The wrapper sets GWS_GATE_REAL to this package's own real binary and
# GWS_SHIM_NAME to the name it was installed as, so the caller's environment
# cannot point the gate at a different binary. The gate script is exec'd from
# its live path on every call, so editing it needs no rebuild and no switch.
#
# Fails CLOSED: a missing or unreadable gate script exits 79 and never falls
# through to the real binary. That is the whole point, so do not "fix" it by
# guessing a fallback.
#
# Enabled per machine. The default is on exactly when the gate script is already
# present on that machine (any OTHER machine importing this repo keeps plain
# gws, unchanged). The bare `gws` package must not stay in home.packages beside
# the wrapper: two packages of the same name cannot share one profile.
{ pkgs, lib, config, ... }:

let
  cfg = config.gwsReadOnly;
  gateScript = toString cfg.gate;
in
{
  options.gwsReadOnly = {
    enable = lib.mkOption {
      type = lib.types.bool;
      # Impure read of the target machine's own filesystem (the flake is applied
      # with --impure). A machine with no gate script is left exactly as it was.
      default = builtins.pathExists gateScript;
      defaultText = lib.literalExpression ''builtins.pathExists "<gate>"'';
      description = ''
        Install the gws wrapper. When false, whatever gws the config already
        installs is used unchanged.
      '';
    };

    gate = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/hermes/nixos/gws-mail-gate.sh";
      description = ''
        Path to the gate script. It is exec'd on every call with GWS_GATE_REAL
        and GWS_SHIM_NAME set, and must exit 79 to refuse a call.
      '';
    };

    name = lib.mkOption {
      type = lib.types.str;
      default = "gws";
      description = "Name the wrapper is installed under.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.writeShellScriptBin cfg.name ''
        real=${pkgs.gws}/bin/gws
        gate=${lib.escapeShellArg gateScript}

        if [ ! -f "$gate" ] || [ ! -r "$gate" ]; then
          echo "${cfg.name}: refusing every call: the gate script $gate is missing or unreadable." >&2
          echo "${cfg.name}: no fallback to the real binary is allowed; restore the script." >&2
          exit 79
        fi

        # Set here, unconditionally, after the caller's environment is inherited.
        GWS_GATE_REAL="$real"
        GWS_SHIM_NAME=${lib.escapeShellArg cfg.name}
        export GWS_GATE_REAL GWS_SHIM_NAME

        # The gate prints its own "send this way instead" text when this is unset.
        # A caller could otherwise hand it a file of its own and have the refusal
        # read as something true of this machine, so drop what it inherited.
        unset GWS_GATE_HELP

        exec ${pkgs.bash}/bin/bash "$gate" "$@"
      '')
    ];
  };
}
