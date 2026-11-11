{pkgs, ...}: {
  # Krohnkite, a tiling KWin script. Windows open floating; Meta+Z tiles the
  # focused one (and floats it again), Meta+Shift+Z does the whole desktop.
  home.packages = [pkgs.kdePackages.krohnkite];

  programs.plasma = {
    configFile.kwinrc = {
      Plugins.krohnkiteEnabled = true;
      Script-krohnkite.floatAsDefault = true;
    };

    # Its defaults, moved off the keys this config already uses. The rest
    # (Meta+Shift/Ctrl+H/J/K/L to move and resize, Meta+\ for the next
    # layout) stay as Krohnkite ships them.
    shortcuts.kwin = {
      # Meta+F maximizes, Meta+Shift+F is fullscreen, Meta+G is Grid View.
      KrohnkiteToggleFloat = "Meta+Z";
      KrohnkiteFloatAll = "Meta+Shift+Z";
      # Meta+Return opens a terminal.
      KrohnkiteSetMaster = "Meta+Shift+Return";
      # Meta+D closes the window.
      KrohnkiteDecrease = "Meta+Shift+I";
      # Meta+T is the terminal, Meta+M maximizes; Meta+\ cycles layouts.
      KrohnkiteTileLayout = [];
      KrohnkiteMonocleLayout = [];
      # Meta+L locks the screen; Meta+Left/Right and Meta+Alt+Up/Down already
      # move focus between windows, tiled ones too.
      KrohnkiteFocusLeft = [];
      KrohnkiteFocusRight = [];
      KrohnkiteFocusUp = [];
      KrohnkiteFocusDown = [];
    };
  };
}
