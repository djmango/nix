# Entry point for Mac/Linux desktops: base + platform extras.
{
  imports = [
    ./home-base.nix
    ./home-darwin.nix
    ./home-linux-extras.nix
  ];
}
