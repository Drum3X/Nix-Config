{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    decoration = {
      rounding = 20;
      rounding_power = 2.0;
      active_opacity = 0.92;
      inactive_opacity = 0.92;
      fullscreen_opacity = 1.0;
      dim_inactive = true;
      dim_strength = 0.1;
      dim_special = 0.1;
      dim_around = 0.1;

      blur = {
        enabled = true;
        size = 8;
        passes = 2;
        ignore_opacity = true;
        new_optimizations = true;
        xray = false;
        noise = 0.01;
        contrast = 1;
        brightness = 1;
        vibrancy = 0.1;
        vibrancy_darkness = 0;
        special = false;
        popups = true;
        popups_ignorealpha = 0.6;
        input_methods = false;
        input_methods_ignorealpha = 0.2;
      };

      shadow = {
        enabled = true;
        range = 16;
        render_power = 2;
        sharp = false;
        ignore_window = true;
        color = "0x55000000";
        color_inactive = "0x55000000";
        offset = "0 4";
        scale = 1;
      };
    };
  };
}
