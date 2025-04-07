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

  [config.custom_colors.red]
  color = '#FF0000'
  blend = true

  [config.custom_colors.green]
  color = '#00FF00'
  blend = true

  [config.custom_colors.yellow]
  color = '#FFFF00'
  blend = true

  [config.custom_colors.blue]
  color = '#0000FF'
  blend = true

  [config.custom_colors.magenta]
  color = '#FF00FF'
  blend = true

  [config.custom_colors.cyan]
  color = '#00FFFF'
  blend = true

  [config.custom_colors.white]
  color = '#FFFFFF'
  blend = true

  [templates.hyprland]
  input_path = '~/.config/matugen/templates/hyprland-colors.conf'
  output_path = '~/.config/hypr/hyprland-colors.conf' 

  [templates.drumshell]
  input_path = '~/.config/matugen/templates/drumshell.scss'
  output_path = '~/.config/ags/drumshell.scss' 

  [templates.kitty]
  input_path = '~/.config/matugen/templates/kitty-colors.conf' 
  output_path = '~/.config/kitty/kitty-colors.conf'

  [templates.gtk3]
  input_path = '~/.config/matugen/templates/gtk-colors.css'
  output_path = '~/.config/gtk-3.0/colors.css'

  [templates.gtk4]
  input_path = '~/.config/matugen/templates/gtk-colors.css'
  output_path = '~/.config/gtk-4.0/colors.css'

  [templates.discord]
  input_path = '~/.config/matugen/templates/discord.css'
  output_path = '~/.config/vesktop/themes/discord.css'
  ";
}
