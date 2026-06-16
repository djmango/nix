# Entry point for Mac/Linux desktops: base + platform extras.
{ pkgs, lib, ... }:

{
  imports =
    [ ./home-base.nix ]
    ++ lib.optionals pkgs.stdenv.isDarwin [ ./home-darwin.nix ]
    ++ lib.optionals pkgs.stdenv.isLinux [ ./home-linux-extras.nix ];
}
