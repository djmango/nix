{ lib, pkgs, config, ... }:
let
  minReleaseAgeDays = 3;
  pnpmMinReleaseAgeMinutes = minReleaseAgeDays * 24 * 60;
  bunMinReleaseAgeSeconds = minReleaseAgeDays * 24 * 60 * 60;
in
{
  # nixpkgs uv may be older than relative exclude-newer ("N days", "PND"); RFC 3339 always works.
  home.activation.uvExcludeNewer = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    _dst="${config.home.homeDirectory}/.config/uv/uv.toml"
    ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$_dst")"
    _ts=$(${pkgs.coreutils}/bin/date -u -d "${toString minReleaseAgeDays} days ago" +%Y-%m-%dT%H:%M:%SZ)
    ${pkgs.coreutils}/bin/printf '%s\n' \
      '# Ignore packages published within the last ${toString minReleaseAgeDays} days (RFC 3339; refreshed on each home activation).' \
      "exclude-newer = \"$_ts\"" \
      > "$_dst"
  '';

  home.file =
    {
      ".npmrc".text = ''
        fund=false
        audit=false
        ; Delay newly published npm packages by ${toString minReleaseAgeDays} days.
        min-release-age=${toString minReleaseAgeDays}
      '';

      ".yarnrc.yml".text = ''
        # Delay newly published npm packages by ${toString minReleaseAgeDays} days.
        npmMinimalAgeGate: "${toString minReleaseAgeDays}d"
      '';

      ".bunfig.toml".text = ''
        [install]
        # Delay newly published npm packages by ${toString minReleaseAgeDays} days.
        minimumReleaseAge = ${toString bunMinReleaseAgeSeconds}
      '';

      ".config/pnpm/config.yaml".text = ''
        # Delay newly published npm packages by ${toString minReleaseAgeDays} days.
        minimumReleaseAge: ${toString pnpmMinReleaseAgeMinutes}
      '';
    }
    // lib.optionalAttrs pkgs.stdenv.isDarwin {
      "Library/Preferences/pnpm/config.yaml".text = ''
        # Delay newly published npm packages by ${toString minReleaseAgeDays} days.
        minimumReleaseAge: ${toString pnpmMinReleaseAgeMinutes}
      '';
    };
}
