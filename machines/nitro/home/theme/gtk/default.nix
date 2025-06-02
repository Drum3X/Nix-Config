{ pkgs, ... }:
{
  gtk = {
    enable = true;
    font = {
      name = "UbuntuSans Nerd Font";
      size = 11;
    };

    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };

    iconTheme = {
      name = "MoreWaita";
      package = pkgs.morewaita-icon-theme;
    };

    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };

    gtk3.extraCss = "@import 'colors.css';";
    gtk4.extraCss = "@import 'colors.css';";
  };
}
