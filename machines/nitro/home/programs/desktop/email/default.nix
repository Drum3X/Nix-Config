{ pkgs, ... }:
{
  home.packages = with pkgs; [
    thunderbird
    tutanota-desktop
  ];
}
