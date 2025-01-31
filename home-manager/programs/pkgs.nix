{ inputs, pkgs, ... }: {
  home.packages = with pkgs; [ 
    inputs.zen-browser.packages."${pkgs.system}".default

    neofetch 
    neovim
    firefox   
    vscodium
    bitwarden-desktop
    dissent
  ];
}