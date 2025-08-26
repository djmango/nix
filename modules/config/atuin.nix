{ pkgs, ... }:
{
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      style = "auto";
      inline_height = 0;
      enter_accept = true;
      keymap_mode = "auto";
    };
  };
}
