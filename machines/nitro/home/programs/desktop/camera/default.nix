{ pkgs, ... }:
{
  home.packages = [
    pkgs.snapshot
  ];
}
