{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "uwsm finalize"
      "hyprlock"
      "hyprctl setcursor Bibata-Modern-Ice 24"
    ];
  };
}
