{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    steam
    protonup-qt
    inputs.prismlauncher.packages.${pkgs.system}.prismlauncher
  ];
}
