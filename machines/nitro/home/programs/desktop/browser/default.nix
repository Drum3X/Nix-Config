{ inputs, pkgs, ... }:
{
  home.packages = [
    inputs.zen-browser.packages."${pkgs.system}".twilight
    pkgs.firefox
    pkgs.tor-browser
  ];
}
