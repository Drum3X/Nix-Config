{ pkgs, ... }:
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
  input_path = '~/.config/matugen/templates/hyprland-colors.conf'
  output_path = '~/.config/hypr/hyprland-colors.conf' 

  [templates.drumshell]
  input_path = '~/.config/matugen/templates/drumshell.scss'
  output_path = '~/drumshell.scss' 

  [templates.kitty]
  input_path = '~/.config/matugen/templates/kitty-colors.conf' 
  output_path = '~/.config/kitty/kitty-colors.conf'

  [templates.gtk3]
  input_path = '~/.config/matugen/templates/gtk-colors.css'
  output_path = '~/.config/gtk-3.0/colors.css'

  [templates.gtk4]
  input_path = '~/.config/matugen/templates/gtk-colors.css'
  output_path = '~/.config/gtk-4.0/colors.css'

  [templates.qt5ct]
  input_path = '~/.config/matugen/templates/qt-colors.conf'
  output_path = '~/.config/qt5ct/colors/matugen.conf'

  [templates.qt6ct]
  input_path = '~/.config/matugen/templates/qt-colors.conf'
  output_path = '~/.config/qt6ct/colors/matugen.conf'

  [templates.discord]
  input_path = '~/.config/matugen/templates/discord.css'
  output_path = '~/.config/vesktop/themes/discord.css'
  ";
}
