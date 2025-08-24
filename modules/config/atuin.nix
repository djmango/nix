{ pkgs, ... }:
{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      style = "auto";
      inline_height = 0;
    };
  };
}
