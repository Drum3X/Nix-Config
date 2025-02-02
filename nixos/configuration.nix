{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ./modules
    ./services
    ./programs
  ];

  system.stateVersion = "24.11";
}
