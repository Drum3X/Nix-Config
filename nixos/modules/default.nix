{ ... }:
{
  imports = [
    ./system.nix
    ./graphics.nix
    ./users.nix
    ./networking.nix
    ./boot.nix
    ./security.nix
    ./bluetooth.nix
    ./garbage.nix
  ];
}
