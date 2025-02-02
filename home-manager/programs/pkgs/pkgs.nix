{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    inputs.zen-browser.packages."${pkgs.system}".default

    neofetch
    neovim
    bitwarden-desktop
    killall
    vesktop
    wl-clipboard
    swww
    pywal
    nautilus
    nwg-look
    pavucontrol
  ];
}
