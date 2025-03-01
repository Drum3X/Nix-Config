{ ... }:
{
  programs.kitty = {
    enable = true;
    settings = {
      include = "~/.cache/wal/colors-kitty.conf";

      confirm_os_window_close = 0;

      font_family = "JetBrainsMono Nerd Font";
      font_size = 12;
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      window_margin_width = 10;
    };
  };
}
