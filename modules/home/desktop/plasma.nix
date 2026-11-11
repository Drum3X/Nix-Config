{
  config,
  lib,
  ...
}: let
  desktops = lib.range 1 6;
  perDesktop = f: lib.listToAttrs (map f desktops);
in {
  # Autostart apps (app-*@autostart.service) wait only for
  # graphical-session.target, and that can outlive a logout: a portal or a
  # DrKonqi crash handler started late keeps it up. The next login then
  # starts them before KWin, and they abort with no display (F-Dpi,
  # DiscoverNotifier). Wait for the Plasma workspace instead.
  xdg.configFile."systemd/user/app-.service.d/10-after-plasma.conf".text = ''
    [Unit]
    After=plasma-workspace.target
  '';

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

    # The task manager lists windows from every virtual desktop, not just the
    # current one. A Plasma script rather than appletsrc keys, whose panel
    # and widget ids differ between installs.
    startup.desktopScript.taskmanager_all_desktops.text = ''
      panels().forEach(function (panel) {
        panel.widgets("org.kde.plasma.icontasks").forEach(function (widget) {
          widget.currentConfigGroup = ["General"];
          widget.writeConfig("showOnlyCurrentDesktop", false);
          widget.reloadConfig();
        });
      });
    '';

    # Log in to an empty desktop: apps open at logout do not come back.
    session.sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";

    kwin.virtualDesktops = {
      # A 3x2 grid: three-finger swipes go up and down a row too.
      number = builtins.length desktops;
      rows = 2;
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
      captureRectangularRegion = "Print";
      captureEntireDesktop = ["Shift+Print" "Meta+Shift+S"];
    };

    shortcuts = {
      "services/org.kde.konsole.desktop"._launch = ["Meta+Return" "Meta+T"];
      "services/google-chrome.desktop"._launch = "Meta+Q";
      "services/thunderbird.desktop"._launch = "Meta+W";
      "services/org.kde.dolphin.desktop"._launch = "Meta+E";
      # Print takes a region now (above); the Spectacle window is on Meta+S.
      "services/org.kde.spectacle.desktop"._launch = "Meta+S";

      plasmashell =
        {
          "activate application launcher" = "Alt+F1";
          # Its default Meta+Q took the key from the browser.
          "manage activities" = [];
        }
        # Meta+1..6 switch desktops instead of activating task manager entries.
        // perDesktop (n: lib.nameValuePair "activate task manager entry ${toString n}" []);

      org_kde_powerdevil."Turn Off Screen" = "Meta+Shift+P";

      kwin =
        {
          "Window Close" = ["Meta+D" "Alt+F4"];
          "Overview" = "Meta+A";
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
        # Ctrl+F1..F4 too, as in Plasma; Ctrl+F5 stays the browser's hard reload.
        // perDesktop (n: lib.nameValuePair "Switch to Desktop ${toString n}" (["Meta+${toString n}"] ++ lib.optional (n <= 4) "Ctrl+F${toString n}"))
        // perDesktop (n: lib.nameValuePair "Window to Desktop ${toString n}" "Meta+Ctrl+${toString n}");
    };
  };
}
