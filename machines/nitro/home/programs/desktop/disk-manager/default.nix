{ pkgs, ... }:
{
  home.packages = [
    pkgs.gnome-disk-utility
    pkgs.baobab
  ];
}
