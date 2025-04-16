{ ... }:
{
  home.sessionVariables = {
    NIXOS_OZONE_WL = 1;
    GDK_BACKEND = "wayland";
    MOZ_ENABLE_WAYLAND = 1;
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    ANKI_WAYLAND = 1;

    WLR_DRM_NO_ATOMIC = 1;
    WLR_BACKEND = "vulkan";
    WLR_RENDERER = "vulkan";
    WLR_NO_HARDWARE_CURSORS = 0;

    DISABLE_QT5_COMPAT = 0;
    QT_AUTO_SCREEN_SCALE_FACTOR = 1;
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
    QT_QPA_PLATFORM = "wayland";
  };
}
