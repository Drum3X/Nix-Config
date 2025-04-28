{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    gestures = {
      workspace_swipe = true;
      workspace_swipe_fingers = 3;
      workspace_swipe_min_fingers = false;
      workspace_swipe_distance = 300;
      workspace_swipe_touch = false;
      workspace_swipe_invert = true;
      workspace_swipe_touch_invert = false;
      workspace_swipe_min_speed_to_force = 30;
      workspace_swipe_cancel_ratio = 0.5;
      workspace_swipe_create_new = true;
      workspace_swipe_direction_lock = true;
      workspace_swipe_direction_lock_threshold = 10;
      workspace_swipe_forever = false;
      workspace_swipe_use_r = false;
    };
  };
}
