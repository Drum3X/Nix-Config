{lib, ...}: let
  desktops = lib.range 1 4;
  perDesktop = f: lib.listToAttrs (map f desktops);
in {
  # The shortcuts of the old ShojiWM setup, on Plasma's own actions. Only the
  # keys below are written; everything else stays as Plasma ships it and can
  # still be changed in System Settings.
  programs.plasma = {
    enable = true;

    kwin.virtualDesktops = {
      number = builtins.length desktops;
      rows = 1;
    };

    input.keyboard = {
      layouts = [{layout = "tr";} {layout = "us";}];
      options = ["grp:alt_shift_toggle"];
      repeatDelay = 300;
      repeatRate = 40;
    };

    krunner.shortcuts.launch = ["Meta+Space" "Meta+A" "Alt+Space" "Alt+F2"];

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
          "activate application launcher" = ["Meta" "Alt+F1"];
        }
        # Meta+1..4 switch desktops instead of activating task manager entries.
        // perDesktop (n: lib.nameValuePair "activate task manager entry ${toString n}" []);

      org_kde_powerdevil."Turn Off Screen" = "Meta+Shift+P";

      kwin =
        {
          "Window Close" = ["Meta+D" "Alt+F4"];
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
