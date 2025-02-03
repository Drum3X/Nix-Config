{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    inputs.zen-browser.packages."${pkgs.system}".default
    pywalfox-native

    neofetch
    neovim
    nemo
    bitwarden-desktop
    vesktop
    nwg-look
    pavucontrol
    obs-studio
    mpv
    plasma5Packages.kdeconnect-kde
    tutanota-desktop
    thunderbird
  ];
}
