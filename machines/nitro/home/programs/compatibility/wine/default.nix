{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wineWowPackages.wayland
    winetricks
  ];
}
