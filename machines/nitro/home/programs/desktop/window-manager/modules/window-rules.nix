{...}: {
  programs.niri.settings.window-rules = [
    {
      geometry-corner-radius = let
        radius = 12.0;
      in {
        bottom-left = radius;
        bottom-right = radius;
        top-left = radius;
        top-right = radius;
      };

      clip-to-geometry = true;
      draw-border-with-background = false;
    }
  ];
}
