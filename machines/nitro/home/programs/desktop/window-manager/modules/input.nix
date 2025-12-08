{...}: {
  programs.niri.settings.input = {
    keyboard.xkb = {
      layout = "tr,us";
      options = "grp:alt_shift_toggle";
    };

    touchpad = {
      tap = true;
      accel-speed = 0.4;
      scroll-factor = 1.0;
    };

    mouse = {
      accel-speed = 0.0;
    };

    mod-key = "Super";
    mod-key-nested = "Alt";
    focus-follows-mouse.enable = true;
    warp-mouse-to-focus.enable = false;
  };
}
