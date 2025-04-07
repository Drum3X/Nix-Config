{ inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ./modules
    ./services
    ./programs

    inputs.home-manager.nixosModules.default
  ];

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
    };
    backupFileExtension = "hm-backup";
  };

  system.stateVersion = "24.11";
}
