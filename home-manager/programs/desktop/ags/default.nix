{ inputs, pkgs, ... }:
{
  imports = [ inputs.ags.homeManagerModules.default ];

  programs.ags = {
    enable = true;
    configDir = ./config;
    extraPackages = with pkgs; [
      inputs.ags.packages.${pkgs.system}.wireplumber
      inputs.ags.packages.${pkgs.system}.notifd
      inputs.ags.packages.${pkgs.system}.battery
      inputs.ags.packages.${pkgs.system}.bluetooth
      inputs.ags.packages.${pkgs.system}.apps
      inputs.ags.packages.${pkgs.system}.auth
      inputs.ags.packages.${pkgs.system}.hyprland
      inputs.ags.packages.${pkgs.system}.mpris
      inputs.ags.packages.${pkgs.system}.network
      inputs.ags.packages.${pkgs.system}.tray
      inputs.ags.packages.${pkgs.system}.io
      inputs.ags.packages.${pkgs.system}.astal3
      inputs.ags.packages.${pkgs.system}.astal4
      inputs.ags.packages.${pkgs.system}.auth
      inputs.ags.packages.${pkgs.system}.cava
      inputs.ags.packages.${pkgs.system}.greet
      inputs.ags.packages.${pkgs.system}.river
      inputs.ags.packages.${pkgs.system}.powerprofiles
      inputs.ags.packages.${pkgs.system}.gjs
    ];
  };
}
