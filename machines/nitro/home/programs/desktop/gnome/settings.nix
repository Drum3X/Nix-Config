{
  config,
  lib,
  ...
}: let
  inherit (lib.hm.gvariant) mkTuple;
in {
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = config.gtk.theme.name;
      icon-theme = config.gtk.iconTheme.name;
      cursor-theme = config.home.pointerCursor.name;
      cursor-size = config.home.pointerCursor.size;
      font-name = "${config.gtk.font.name} ${toString config.gtk.font.size}";
      monospace-font-name = "JetBrains Mono Nerd Font 10";
    };

    "org/gnome/desktop/input-sources" = {
      sources = [
        (mkTuple ["xkb" "tr"])
        (mkTuple ["xkb" "us"])
      ];
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      speed = 0.4;
    };

    "org/gnome/desktop/peripherals/mouse" = {
      speed = 0.0;
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = false;
    };
    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 9;
    };

    "org/gnome/shell" = {
      favorite-apps = [
        "chromium-browser.desktop"
        "com.mitchellh.ghostty.desktop"
        "org.gnome.Nautilus.desktop"
        "com.obsproject.Studio.desktop"
      ];
    };
  };
}
