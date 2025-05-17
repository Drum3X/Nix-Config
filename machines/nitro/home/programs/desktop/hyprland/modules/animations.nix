{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    animations = {
      enabled = true;
      first_launch_animation = true;

      bezier = [
        "decel, 0.05, 0.7, 0.1, 1"
        "accel, 0.3, 0, 0.8, 0.15"
        "menu_decel, 0.1, 1, 0, 1"
        "menu_accel, 0.38, 0.04, 1, 0.07"
      ];
      
      animation = [
        "windowsIn, 1, 3, decel, popin 80%"
        "windowsOut, 1, 3, accel, popin 80%"
        "windowsMove, 1, 3, menu_decel"
        "layersIn, 1, 3, menu_decel, fade"
        "layersOut, 1, 1.6, menu_accel, fade"
        "fadeIn, 1, 3, decel"
        "fadeOut, 1, 3, decel"
        "fadeSwitch, 0"
        "fadeShadow, 0, 7, accel"
        "fadeDim, 1, 2, accel"
        "fadeLayers, 1, 2, menu_decel"
        "fadeLayersIn, 1, 2, menu_decel"
        "fadeLayersOut, 1, 4.5, menu_accel"
        "border, 1, 2, accel"
        "borderangle, 0"
        "workspacesIn, 1, 7, menu_decel, slide"
        "workspacesOut, 1, 7, menu_decel, slide"
        "specialWorkspaceIn, 1, 3, menu_decel, fade"
        "specialWorkspaceOut, 1, 3, menu_decel, fade"
      ];
    };
  };
}
