{ ... }:
{
  imports = [
    ./hardware.nix
    ./nixos.nix
    ./graphics.nix
    ./users.nix
    ./networking.nix
    ./boot.nix
    ./time.nix
    ./nixpkgs.nix
    ./security.nix
    ./bluetooth.nix
    ./garbage.nix
    ./home.nix
  ];
}
