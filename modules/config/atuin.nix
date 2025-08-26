{ pkgs, ... }:
{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      style = "auto";
      inline_height = 0;
      enter_accept = true;
      keymap_mode = "auto";
    };
  };
}
