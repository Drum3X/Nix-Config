{ pkgs, ... }:
{
  home.packages = with pkgs; [
    steam
    lutris
    bottles
    protonup
  ];
}
