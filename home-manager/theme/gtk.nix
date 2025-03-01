{ pkgs, ... }:
{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    inter-nerdfont
    nerd-fonts.mononoki
    noto-fonts
    adw-gtk3
  ];

  gtk = {
    enable = true;
    font = {
      name = "Inter Nerd Font";
      size = 11;
    };

    theme = {
      name = "adw-gtk3-dark";
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme.override { color = "black"; };
    };

    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };
  };

  home.sessionVariables.GTK_THEME = "linea-nord-color";

  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
  };
}
