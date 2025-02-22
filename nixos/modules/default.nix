{ ... }:
{
  imports = [
    ./system.nix
    ./users.nix
    ./networking.nix
    ./boot.nix
    ./bluetooth.nix
    ./garbage.nix
  ];
}
