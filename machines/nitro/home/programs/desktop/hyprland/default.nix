{ ... }:
{
  imports = [
    ./modules
    ./hyprlock
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = false;
  };
}
