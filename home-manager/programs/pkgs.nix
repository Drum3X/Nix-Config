{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    inputs.zen-browser.packages."${pkgs.system}".default

    neofetch
    neovim
    firefox
    bitwarden-desktop
    dissent
  ];
}
