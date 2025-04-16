{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.libnotify
  ];
}
