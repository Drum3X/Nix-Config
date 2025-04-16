{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.gparted
  ];
}
