{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    brightnessctl
    playerctl
    libnotify
  ];
}
