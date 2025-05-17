{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    general = {
      border_size = 1;
      no_border_on_floating = false;
      gaps_in = 8;
      gaps_out = 16;
      gaps_workspaces = 0;
      "col.active_border" = "$primary";
      "col.inactive_border" = "$background";
      layout = "dwindle";
      no_focus_fallback = true;
      resize_on_border = false;
      extend_border_grab_area = 1;
      hover_icon_on_border = true;
      allow_tearing = false;
      resize_corner = 0;

      snap = {
        enabled = false;
        window_gap = 10;
        monitor_gap = 10;
        border_overlap = true;
      };
    };
  };
}
