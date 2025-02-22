{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    steam
    protonup-qt
  ];
}
