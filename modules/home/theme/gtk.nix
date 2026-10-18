{
  config,
  pkgs,
  ...
}: {
  # Light by default; darkman (../desktop/darkman.nix) flips gtk-theme and
  # color-scheme in dconf at sunset, which GTK 3, GTK 4 and libadwaita all follow.
  gtk = {
    enable = true;

    font = {
      name = "Inter";
      package = pkgs.inter;
      size = 10;
    };

    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      name = "adw-gtk3";
      package = pkgs.adw-gtk3;
    };

    gtk4.theme = null;
  };

  dconf.settings."org/gnome/desktop/interface" = {
    icon-theme = config.gtk.iconTheme.name;
    cursor-theme = config.home.pointerCursor.name;
    cursor-size = config.home.pointerCursor.size;
    font-name = "${config.gtk.font.name} ${toString config.gtk.font.size}";
    monospace-font-name = "JetBrains Mono Nerd Font 10";
  };

  dconf.settings."org/gnome/desktop/wm/preferences" = {
    button-layout = "close,minimize,maximize:";
  };
}
