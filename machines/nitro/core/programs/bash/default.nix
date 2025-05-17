{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.bash
  ];
}
