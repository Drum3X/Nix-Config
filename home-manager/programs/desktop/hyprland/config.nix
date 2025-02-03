{ ... }:
{
  wayland.windowManager.hyprland = {
    settings = {
      source = "~/.cache/wal/colors-hyprland.conf";

      exec-once = [
        "ags run"
        "swww init"
        "hyprctl setcursor Bibata-Modern-Ice 24"
      ];

      input = {
        kb_layout = "us,tr";
        kb_options = "grp:alt_caps_toggle";
        sensitivity = 0.5;
        touchpad = {
          natural_scroll = true;
        };
      };

      dwindle = {
        force_split = 0;
        special_scale_factor = 1.0;
        split_width_multiplier = 1.0;
        use_active_for_splits = true;
        pseudotile = "yes";
        preserve_split = "yes";
      };

      animations = {
        enabled = true;

        bezier = [
          "fluent_decel, 0, 0.2, 0.4, 1"
          "easeOutCirc, 0, 0.55, 0.45, 1"
          "easeOutCubic, 0.33, 1, 0.68, 1"
          "fade_curve, 0, 0.55, 0.45, 1"
        ];

        animation = [
          "windowsIn,   0, 4, easeOutCubic,  popin 20%"
          "windowsOut,  0, 4, fluent_decel,  popin 80%"
          "windowsMove, 1, 2, fluent_decel, slide"

          "fadeIn,      1, 3,   fade_curve"
          "fadeOut,     1, 3,   fade_curve"
          "fadeSwitch,  0, 1,   easeOutCirc"
          "fadeShadow,  1, 10,  easeOutCirc"
          "fadeDim,     1, 4,   fluent_decel"

          "workspaces,  1, 4,   easeOutCubic, fade"
        ];
      };

      general = {
        "$mainMod" = "SUPER";
        layout = "dwindle";
        gaps_in = 5;
        gaps_out = 10;
        border_size = 4;
        "col.active_border" = "$color3 $color4 45deg";
        "col.inactive_border" = "0x00000000";
        border_part_of_window = false;
        no_border_on_floating = false;
      };

      misc = {
        disable_autoreload = false;
        disable_hyprland_logo = true;
        always_follow_on_dnd = true;
        layers_hog_keyboard_focus = true;
        animate_manual_resizes = false;
        enable_swallow = true;
        focus_on_activate = true;
        new_window_takes_over_fullscreen = 2;
        middle_click_paste = false;
      };

      decoration = {
        rounding = 8;
        active_opacity = 0.92;
        inactive_opacity = 0.88;
        fullscreen_opacity = 1.0;

        blur = {
          enabled = true;
          size = 6;
          passes = 2;
          brightness = 1;
          contrast = 1.7;
          ignore_opacity = true;
          noise = 0;
          new_optimizations = true;
          xray = true;
        };

        shadow = {
          enabled = true;
          ignore_window = true;
          offset = "0 2";
          range = 20;
          render_power = 3;
          color = "rgba(00000055)";
        };
      };

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      bindl = [
        "$mainMod, XF86AudioMute, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle"
        ",XF86AudioMute, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%"
        "$mainMod SHIFT, M, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%"
      ];

      bindle = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      bind = [
        "$mainMod, d, killactive,"
        "$mainMod, t, exec, kitty"
        "$mainMod, Return, exec, kitty"
        "$mainMod, z, exec, zen"
        "$mainMod, v, exec, codium"
        "$mainMod, e, exec, nemo"
        "$mainMod, s, exec, wofi --show drun || pkill wofi"

        "$mainMod, f, fullscreen, 0"
        "$mainMod SHIFT, f, fullscreen, 1"

        "$mainMod, Space, togglefloating,"

        "$mainMod SHIFT, q, exit,"

        "$mainMod SHIFT, r, exec, ags quit & ags run"

        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        "$mainMod, h, movefocus, l"
        "$mainMod, j, movefocus, d"
        "$mainMod, k, movefocus, u"
        "$mainMod, l, movefocus, r"

        "$mainMod CTRL, left, resizeactive, -40 0"
        "$mainMod CTRL, right, resizeactive, 40 0"
        "$mainMod CTRL, up, resizeactive, 0 -40"
        "$mainMod CTRL, down, resizeactive, 0 40"
        "$mainMod CTRL, h, resizeactive, -40 0"
        "$mainMod CTRL, j, resizeactive, 0 40"
        "$mainMod CTRL, k, resizeactive, 0 -40"
        "$mainMod CTRL, l, resizeactive, 40 0"

        "$mainMod SHIFT, left, movewindow, l"
        "$mainMod SHIFT, right, movewindow, r"
        "$mainMod SHIFT, up, movewindow, u"
        "$mainMod SHIFT, down, movewindow, d"
        "$mainMod SHIFT, h, movewindow, l"
        "$mainMod SHIFT, j, movewindow, d"
        "$mainMod SHIFT, k, movewindow, u"
        "$mainMod SHIFT, l, movewindow, r"

        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        "$mainMod SHIFT, 1, movetoworkspacesilent, 1"
        "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
        "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
        "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
        "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
        "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
        "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
        "$mainMod SHIFT, 8, movetoworkspacesilent, 8"
        "$mainMod SHIFT, 9, movetoworkspacesilent, 9"
        "$mainMod SHIFT, 0, movetoworkspacesilent, 10"
      ];
    };

    extraConfig = "
      monitor=eDP-1, 1920x1080@144, 0x0, 1
    ";
  };
}
