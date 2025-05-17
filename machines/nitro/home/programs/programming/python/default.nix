{ pkgs, ... }:
{
  home.packages = [
    pkgs.python3Full
    pkgs.python3Packages.pip
    pkgs.python3Packages.virtualenv
  ];
}
