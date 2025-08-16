{
  pkgs,
  user,
  nvimcfg,
  ...
}:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.${user} =
    { pkgs, ... }:
    {
      home.stateVersion = "24.05";
      programs.home-manager.enable = true;

      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        withNodeJs = true;
        withPython3 = true;
      };
      xdg.configFile."nvim".source = nvimcfg;

      programs.atuin.enable = true;
      programs.zoxide.enable = true;

      home.packages = with pkgs; [
        uv
        fd
        magic-wormhole
        rustc
        cargo
        rust-analyzer
        clippy
      ];
    };
}
