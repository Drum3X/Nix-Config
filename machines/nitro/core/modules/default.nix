{ ... }:
{
  imports = [
    ./boot.nix
    ./bootloader.nix
    ./filesystems.nix
    ./hardware.nix
    ./i18n.nix
    ./networking.nix
    ./nixpkgs.nix
    ./time.nix
    ./users.nix
  ];
}
