{pkgs, ...}: {
  # Krohnkite, a tiling KWin script. Windows open tiled; Meta+Z floats the
  # focused one (and tiles it again), Meta+Shift+Z does the whole desktop.
  home.packages = [pkgs.kdePackages.krohnkite];

  programs.plasma = {
    configFile.kwinrc = {
      Plugins.krohnkiteEnabled = true;
      Script-krohnkite = {
        # Gaps around and between tiles. The panel dodges windows instead of
        # reserving space, so the bottom gap clears it by hand: 48 px thick,
        # floating 8 px up, plus the 24 px gap.
        screenGapTop = 24;
        screenGapLeft = 24;
        screenGapRight = 24;
        screenGapBottom = 80;
        screenGapBetween = 12;
      };
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
