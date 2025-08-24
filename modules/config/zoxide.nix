{ pkgs, ... }:
{
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    flags = [
      "--cmd cd"
    ];
  };
}
