{ lib, pkgs, ... }:
let
  minReleaseAgeDays = 7;
  pnpmMinReleaseAgeMinutes = minReleaseAgeDays * 24 * 60;
  bunMinReleaseAgeSeconds = minReleaseAgeDays * 24 * 60 * 60;
in
{
  home.file =
    {
      ".npmrc".text = ''
        fund=false
        audit=false
        ; Delay newly published npm packages by 7 days.
        min-release-age=${toString minReleaseAgeDays}
      '';

      ".yarnrc.yml".text = ''
        # Delay newly published npm packages by 7 days.
        npmMinimalAgeGate: "7d"
      '';

      ".bunfig.toml".text = ''
        [install]
        # Delay newly published npm packages by 7 days.
        minimumReleaseAge = ${toString bunMinReleaseAgeSeconds}
      '';

      ".config/pnpm/config.yaml".text = ''
        # Delay newly published npm packages by 7 days.
        minimumReleaseAge: ${toString pnpmMinReleaseAgeMinutes}
      '';

      ".config/uv/uv.toml".text = ''
        # Ignore packages published within the last 7 days.
        exclude-newer = "7 days"
      '';
    }
    // lib.optionalAttrs pkgs.stdenv.isDarwin {
      "Library/Preferences/pnpm/config.yaml".text = ''
        # Delay newly published npm packages by 7 days.
        minimumReleaseAge: ${toString pnpmMinReleaseAgeMinutes}
      '';
    };
}
