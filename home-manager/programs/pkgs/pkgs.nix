{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    inputs.zen-browser.packages."${pkgs.system}".default
    pywalfox-native

    neovim
    nemo
    nautilus
    bitwarden-desktop
    stable.vesktop
    stable.electron-bin
    nwg-look
    xsettingsd
    pavucontrol
    blueman
    obs-studio
    mpv
    plasma5Packages.kdeconnect-kde
    tutanota-desktop
    thunderbird
    gimp
    nushell
    screenshot

    nodejs
    php
  ];
}
