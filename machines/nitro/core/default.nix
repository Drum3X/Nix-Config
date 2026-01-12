{inputs, ...}: {
  imports = [
    inputs.home-manager.nixosModules.default

    ./modules
    ./programs
    ./services
  ];

  system.stateVersion = "25.05";
}
