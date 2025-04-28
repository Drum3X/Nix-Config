{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    input = {
      kb_layout = "tr, us";
      kb_variant = "";
      kb_options = "grp:alt_caps_toggle, caps:swapescape";
      numlock_by_default = false;
      resolve_binds_by_sym = false;
      repeat_rate = 40;
      repeat_delay = 400;
      sensitivity = 0.0;
      force_no_accel = false;
      left_handed = false;
      scroll_button = 0;
      scroll_button_lock = false;
      scroll_factor = 1.0;
      natural_scroll = false;
      follow_mouse = 1;
      focus_on_close = 0;
      mouse_refocus = true;
      float_switch_override_focus = 1;
      special_fallthrough = false;
      off_window_axis_events = 1;
      emulate_discrete_scroll = 1;

      touchpad = {
        disable_while_typing = true;
        natural_scroll = true;
        scroll_factor = 0.3;
        middle_button_emulation = false;
        clickfinger_behavior = false;
        tap-to-click = true;
        drag_lock = false;
        tap-and-drag = true;
      };
    };
  };
}
