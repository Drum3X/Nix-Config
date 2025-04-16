{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.playerctl
  ];
}
