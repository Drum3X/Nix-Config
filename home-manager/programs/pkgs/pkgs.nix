{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    inputs.zen-browser.packages."${pkgs.system}".default
    pywalfox-native

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
    gimp
    slurp
    wayshot
    swappy
    nushell
  ];
}
