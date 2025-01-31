{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./programs
  ];
  
  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
    ];
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = "drum3x";
    homeDirectory = "/home/drum3x";
    enableNixpkgsReleaseCheck = false;
  };

  programs.home-manager.enable = true; 

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "24.11";
}
