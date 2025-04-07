{ pkgs, inputs, ... }:
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

  environment.systemPackages = [
    pkgs.gtk4-layer-shell
    pkgs.gtk4
  ];

  system.stateVersion = "24.11";
}
