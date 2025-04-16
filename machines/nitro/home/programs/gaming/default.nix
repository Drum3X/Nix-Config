{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    inputs.prismlauncher.packages.${pkgs.system}.prismlauncher

    steam
    heroic
    lutris
    bottles
    protonup-qt
  ];
}
