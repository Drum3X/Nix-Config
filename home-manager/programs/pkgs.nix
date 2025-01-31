{ pkgs, ... }: {
  home.packages = with pkgs; [ 
    neofetch 
    neovim
    firefox
    vscodium
    bitwarden-desktop
    dissent
  ];
}