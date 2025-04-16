{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nautilus
    file-roller
    unrar
    unar
    ntfs3g
  ];
}
