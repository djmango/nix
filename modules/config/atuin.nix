{ pkgs, ... }:
{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    style = "auto";
    inline_height = 0;
  };
}
