{ inputs, pkgs, ... }:
{

  home.packages = with pkgs; [
    inputs.zen-browser.packages."${pkgs.system}".default
    pywalfox-native

    neovim
    gparted
    ntfs3g
    nautilus
    eog
    kdePackages.ark
    bitwarden-desktop
    stable.vesktop
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
    qbittorrent
    nushell
    screenshot
    glib

    nodejs
    php

  ];
}
