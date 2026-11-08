{
  config,
  pkgs,
  ...
}: {
  # Light adw-gtk3 by default. GTK 4 / libadwaita follow the color scheme COSMIC
  # publishes through its portal.
  gtk = {
    enable = true;

    font = {
      name = "SF Pro Text";
      size = 10;
    };

    iconTheme = {
      name = "Colloid";
      package = pkgs.colloid-icon-theme;
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
    monospace-font-name = "SF Mono 10";
  };

  dconf.settings."org/gnome/desktop/wm/preferences" = {
    button-layout = ":minimize,maximize,close";
  };
}
