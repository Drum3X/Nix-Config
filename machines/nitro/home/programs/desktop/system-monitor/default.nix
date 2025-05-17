{ pkgs, ... }:
{
  home.packages = [
    pkgs.gnome-system-monitor
    pkgs.gnome-control-center
  ];
}
