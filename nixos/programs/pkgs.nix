{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    home-manager
    brightnessctl
    playerctl
    libnotify
    gparted
  ];
}
