{ inputs, pkgs, ... }:
{

  home.packages = with pkgs; [
    inputs.zen-browser.packages."${pkgs.system}".default
    inputs.ags.packages.${pkgs.system}.io

    tor-browser

    pywalfox-native

    neovim
    gparted
    ntfs3g
    nautilus
    file-roller
    unrar
    unar
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
    gpu-screen-recorder
    gpu-screen-recorder-gtk
    kdePackages.kdenlive

    nodejs
    php

  ];
}
