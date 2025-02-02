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
    nautilus
    nwg-look
    pavucontrol
    adw-gtk3
  ];
}
