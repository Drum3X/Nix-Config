{ ... }:
{
  programs.hyprlock = {
    enable = true;

    settings = {
      source = "hyprland-colors.conf";

      general = {
        disable_loading_bar = true;
        immediate_render = true;
        hide_cursor = true;
        no_fade_in = true;
      };

      bezier = [
        "decel, 0.05, 0.7, 0.1, 1"
        "menu_decel, 0.1, 1, 0, 1"
      ];

      animation = [
        "fadeIn, 1, 3, menu_decel"
        "fadeOut, 1, 3, menu_decel"
        "inputFieldColors, 1, 2, decel"
        "inputFieldFade, 1, 3, menu_decel"
        "inputFieldWidth, 0"
        "inputFieldDots, 1, 2, decel"
      ];

      background = [
        {
          monitor = "";
          path = "/home/drum3x/wallpaper.png";
        }
      ];

      input-field = [
        {
          monitor = "eDP-1";

          size = "320, 48";
          valign = "bottom";
          position = "0%, 7%";

          outline_thickness = 2;

          font_color = "$primary";
          outer_color = "$primary";
          inner_color = "$background";
          check_color = "$secondary";
          fail_color = "$error";

          fade_on_empty = false;
          placeholder_text = "Enter Password";

          dots_spacing = 0.2;
          dots_center = true;
          dots_fade_time = 100;
        }
      ];

      label = [
        {
          monitor = "";
          text = "$TIME";
          font_size = 96;
          color = "$background";

          position = "3%, 5%";

          halign = "left";
          valign = "bottom";
        }
        {
          monitor = "";
          text = "cmd[update:3600000] date +'%d %b %a'";
          font_size = 24;
          color = "$background";

          position = "3%, 3%";

          halign = "left";
          valign = "bottom";
        }
      ];
    };
  };
}
