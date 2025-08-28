{ inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.default

    ./modules
    ./services
    ./programs
  ];

  system.stateVersion = "25.05";
}
