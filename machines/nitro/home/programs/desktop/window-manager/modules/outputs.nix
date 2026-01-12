{...}: {
  programs.niri.settings.outputs = {
    "eDP-1" = {
      mode = {
        width = 1920;
        height = 1080;
        refresh = 144.00;
      };

      scale = 1.0;
      position = {
        x = 0;
        y = 0;
      };
    };
  };
}
