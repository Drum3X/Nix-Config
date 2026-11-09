{
  config,
  lib,
  ...
}: let
  desktops = lib.range 1 4;
  perDesktop = f: lib.listToAttrs (map f desktops);
in {
  # The shortcuts of the old ShojiWM setup, on Plasma's own actions. Only the
  # keys below are written; everything else stays as Plasma ships it and can
  # still be changed in System Settings.
  programs.plasma = {
    enable = true;

    # A new one every minute. The images stay out of the repo (about 60 MB):
    # copy the folder over by hand on a new machine.
    workspace.wallpaperSlideShow = {
      path = "${config.home.homeDirectory}/Pictures/Wallpapers";
      interval = 60;
    };

    # Log in to an empty desktop: apps open at logout do not come back.
    session.sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";

    kwin.virtualDesktops = {
      number = builtins.length desktops;
      rows = 1;
    };
    # Switching desktops slides the windows only; the wallpaper stays put.
    configFile.kwinrc.Effect-slide.SlideBackground = false;

    input.keyboard = {
      layouts = [{layout = "tr";} {layout = "us";}];
      options = ["grp:alt_shift_toggle"];
      repeatDelay = 300;
      repeatRate = 40;
    };

    # Meta on its own: a plain global shortcut since Plasma 6.8 (kwinrc
    # ModifierOnlyShortcuts is gone). The application launcher gave it up.
    krunner.shortcuts.launch = ["Meta" "Meta+Space" "Alt+Space" "Alt+F2"];

    spectacle.shortcuts = {
      captureRectangularRegion = ["Print" "Meta+Shift+S"];
      captureEntireDesktop = "Shift+Print";
    };

    shortcuts = {
      "services/org.kde.konsole.desktop"._launch = ["Meta+Return" "Meta+T"];
      "services/google-chrome.desktop"._launch = "Meta+Q";
      "services/org.kde.dolphin.desktop"._launch = "Meta+E";
      # Print takes a region now (above), not the Spectacle window.
      "services/org.kde.spectacle.desktop"._launch = [];

      plasmashell =
        {
          "activate application launcher" = "Alt+F1";
        }
        # Meta+1..4 switch desktops instead of activating task manager entries.
        // perDesktop (n: lib.nameValuePair "activate task manager entry ${toString n}" []);

      org_kde_powerdevil."Turn Off Screen" = "Meta+Shift+P";

      kwin =
        {
          "Window Close" = ["Meta+D" "Alt+F4"];
          "Overview" = ["Meta+A" "Meta+W"];
          "Show Desktop" = [];
          "Window Maximize" = ["Meta+F" "Meta+M" "Meta+PgUp"];
          "Window Fullscreen" = "Meta+Shift+F";
          # Meta+T opens a terminal.
          "Edit Tiles" = [];

          "Switch Window Left" = "Meta+Left";
          "Switch Window Right" = "Meta+Right";
          "Window Quick Tile Left" = "Meta+Shift+Left";
          "Window Quick Tile Right" = "Meta+Shift+Right";

          "Switch to Previous Desktop" = "Meta+Ctrl+Up";
          "Switch to Next Desktop" = "Meta+Ctrl+Down";
          "Switch One Desktop Up" = [];
          "Switch One Desktop Down" = [];
          "Window to Previous Desktop" = "Meta+Shift+Up";
          "Window to Next Desktop" = "Meta+Shift+Down";
        }
        // perDesktop (n: lib.nameValuePair "Switch to Desktop ${toString n}" ["Meta+${toString n}" "Ctrl+F${toString n}"])
        // perDesktop (n: lib.nameValuePair "Window to Desktop ${toString n}" "Meta+Ctrl+${toString n}");
    };
  };
}
