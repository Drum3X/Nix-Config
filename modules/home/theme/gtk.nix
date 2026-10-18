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

    # GTK3 reads this from settings.ini rather than dconf.
    gtk3.extraConfig.gtk-decoration-layout = ":";
    gtk4.extraConfig.gtk-decoration-layout = ":";
  };

  dconf.settings."org/gnome/desktop/interface" = {
    icon-theme = config.gtk.iconTheme.name;
    cursor-theme = config.home.pointerCursor.name;
    cursor-size = config.home.pointerCursor.size;
    font-name = "${config.gtk.font.name} ${toString config.gtk.font.size}";
    monospace-font-name = "SF Mono 10";
  };

  dconf.settings."org/gnome/desktop/wm/preferences" = {
    # No window buttons in GTK headerbars: ShojiWM draws the traffic lights.
    button-layout = ":";
  };
}
