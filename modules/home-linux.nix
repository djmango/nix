# Full Linux Home Manager profile (base + linux extras).
{ ... }:

{
  imports = [
    ./home-base.nix
    ./home-linux-extras.nix
  ];
}
