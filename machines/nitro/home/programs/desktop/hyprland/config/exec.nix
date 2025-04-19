{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "ags run"
      "swww init"
      "hyprctl setcursor Bibata-Modern-Ice 24"
    ];
  };
}
