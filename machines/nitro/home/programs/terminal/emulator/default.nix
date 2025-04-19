{ pkgs, ... }:
{
  home.packages = [
    pkgs.ghostty
  ];

  xdg.configFile."ghostty/config".text = ''
    font-family = JetBrainsMono Nerd Font
    theme = matugen
    window-padding-x = 12
    window-padding-y = 6
    window-decoration = auto
    window-theme = system
    window-height = 26
    window-width = 90
    copy-on-select = true
    gtk-single-instance = false
    gtk-titlebar = false
    confirm-close-surface = false

    keybind = ctrl+shift+minus=decrease_font_size:1
    keybind = ctrl+shift+minus=decrease_font_size:1
  '';
}
