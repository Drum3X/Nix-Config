{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    matugen
  ];

  home.file.".config/matugen/templates".source = ./templates;

  xdg.configFile."matugen/config.toml".text =
    "
  [config.wallpaper]
  command = 'swww'
  arguments = ['img', '--transition-type', 'center']
  set = true

  [templates.hyprland]
  input_path = '${config.home.homeDirectory}/.config/matugen/templates/hyprland-colors.conf'
  output_path = '${config.home.homeDirectory}/.config/hypr/hyprland-colors.conf'
  post_hook = 'hyprctl reload'

  [templates.drumshell]
  input_path = '${config.home.homeDirectory}/.config/matugen/templates/drumshell.scss'
  output_path = '${config.home.homeDirectory}/.cache/colors.scss'
  post_hook = 'ags request reload'

  [templates.ghostty]
  input_path = '${config.home.homeDirectory}/.config/matugen/templates/ghostty'
  output_path = '${config.home.homeDirectory}/.config/ghostty/themes/matugen'

  [templates.gtk3]
  input_path = '${config.home.homeDirectory}/.config/matugen/templates/gtk-colors.css'
  output_path = '${config.home.homeDirectory}/.config/gtk-3.0/colors.css'

  [templates.gtk4]
  input_path = '${config.home.homeDirectory}/.config/matugen/templates/gtk-colors.css'
  output_path = '${config.home.homeDirectory}/.config/gtk-4.0/colors.css'

  [templates.qt5ct]
  input_path = '${config.home.homeDirectory}/.config/matugen/templates/qt-colors.conf'
  output_path = '${config.home.homeDirectory}/.config/qt5ct/colors/matugen.conf'

  [templates.qt6ct]
  input_path = '${config.home.homeDirectory}/.config/matugen/templates/qt-colors.conf'
  output_path = '${config.home.homeDirectory}/.config/qt6ct/colors/matugen.conf'

  [templates.discord]
  input_path = '${config.home.homeDirectory}/.config/matugen/templates/discord.css'
  output_path = '${config.home.homeDirectory}/.config/vesktop/themes/discord.css'
  ";
}
