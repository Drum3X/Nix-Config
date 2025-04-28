{ ... }:
{
  imports = [
    ./hardware.nix
    ./boot.nix
    ./bootloader.nix
    ./nixos.nix
    ./disko.nix
    ./graphics.nix
    ./users.nix
    ./networking.nix
    ./time.nix
    ./nixpkgs.nix
    ./security.nix
    ./bluetooth.nix
    ./garbage.nix
    ./home.nix
  ];
}
