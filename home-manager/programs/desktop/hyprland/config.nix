{ ... }:
{
  wayland.windowManager.hyprland = {
    settings = {
      source = "hyprland-colors.conf";

      exec-once = [
        "ags run"
        "swww init"
        "hyprctl setcursor Bibata-Modern-Ice 24"
      ];

      monitor = [
        "eDP-1, 1920x1080@144, 0x0, 1"
      ];

      general = {
        border_size = 1;
        no_border_on_floating = false;
        gaps_in = 8;
        gaps_out = 16;
        gaps_workspaces = 30;
        "col.active_border" = "$primary";
        "col.inactive_border" = "$background";
        layout = "dwindle";
        no_focus_fallback = true;
        resize_on_border = false;
        extend_border_grab_area = 1;
        hover_icon_on_border = true;
        allow_tearing = false;
        resize_corner = 0;

        snap = {
          enabled = false;
          window_gap = 10;
          monitor_gap = 10;
          border_overlap = true;
        };
      };

      decoration = {
        rounding = 20;
        rounding_power = 2.0;
        active_opacity = 0.92;
        inactive_opacity = 0.92;
        fullscreen_opacity = 1.0;
        dim_inactive = true;
        dim_strength = 0.1;
        dim_special = 0.1;
        dim_around = 0.1;

        blur = {
          enabled = true;
          size = 12;
          passes = 3;
          ignore_opacity = true;
          new_optimizations = true;
          xray = true;
          noise = 0.01;
          contrast = 1;
          brightness = 1;
          vibrancy = 0.1;
          vibrancy_darkness = 0;
          special = false;
          popups = true;
          popups_ignorealpha = 0.6;
          input_methods = false;
          input_methods_ignorealpha = 0.2;
        };

        shadow = {
          enabled = true;
          range = 16;
          render_power = 2;
          sharp = false;
          ignore_window = true;
          color = "0x55000000";
          color_inactive = "0x55000000";
          offset = "0 4";
          scale = 1;
        };
      };

      animations = {
        enabled = true;
        first_launch_animation = true;

        bezier = [
          "linear, 0, 0, 1, 1"
          "md3_standard, 0.2, 0, 0, 1"
          "md3_decel, 0.05, 0.7, 0.1, 1"
          "md3_accel, 0.3, 0, 0.8, 0.15"
          "overshot, 0.05, 0.9, 0.1, 1.1"
          "crazyshot, 0.1, 1.5, 0.76, 0.92"
          "hyprnostretch, 0.05, 0.9, 0.1, 1.0"
          "menu_decel, 0.1, 1, 0, 1"
          "menu_accel, 0.38, 0.04, 1, 0.07"
          "easeInOutCirc, 0.85, 0, 0.15, 1"
          "easeOutCirc, 0, 0.55, 0.45, 1"
          "easeOutExpo, 0.16, 1, 0.3, 1"
          "softAcDecel, 0.26, 0.26, 0.15, 1"
          "md2, 0.4, 0, 0.2, 1"
        ];
        animation = [
          "windows, 1, 3, md3_decel, popin 60%"
          "windowsIn, 1, 3, md3_decel, popin 60%"
          "windowsOut, 1, 3, md3_accel, popin 60%"
          "border, 1, 10, default"
          "fade, 1, 3, md3_decel"
          "layersIn, 1, 3, menu_decel, slide"
          "layersOut, 1, 1.6, menu_accel"
          "fadeLayersIn, 1, 2, menu_decel"
          "fadeLayersOut, 1, 4.5, menu_accel"
          "workspaces, 1, 7, menu_decel, slide"
          "specialWorkspace, 1, 3, md3_decel, slidevert"
        ];
      };

      input = {
        kb_layout = "tr, us";
        kb_variant = "";
        kb_options = "grp:alt_caps_toggle, caps:swapescape";
        numlock_by_default = false;
        resolve_binds_by_sym = false;
        repeat_rate = 40;
        repeat_delay = 400;
        sensitivity = 0.0;
        force_no_accel = false;
        left_handed = false;
        scroll_button = 0;
        scroll_button_lock = false;
        scroll_factor = 1.0;
        natural_scroll = false;
        follow_mouse = 1;
        focus_on_close = 0;
        mouse_refocus = true;
        float_switch_override_focus = 1;
        special_fallthrough = false;
        off_window_axis_events = 1;
        emulate_discrete_scroll = 1;

        touchpad = {
          disable_while_typing = true;
          natural_scroll = true;
          scroll_factor = 0.4;
          middle_button_emulation = false;
          clickfinger_behavior = false;
          tap-to-click = true;
          drag_lock = false;
          tap-and-drag = true;
        };
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
        workspace_swipe_min_fingers = false;
        workspace_swipe_distance = 300;
        workspace_swipe_touch = false;
        workspace_swipe_invert = true;
        workspace_swipe_touch_invert = false;
        workspace_swipe_min_speed_to_force = 30;
        workspace_swipe_cancel_ratio = 0.5;
        workspace_swipe_create_new = true;
        workspace_swipe_direction_lock = true;
        workspace_swipe_direction_lock_threshold = 10;
        workspace_swipe_forever = false;
        workspace_swipe_use_r = false;
      };

      group = {
        auto_group = true;
        insert_after_current = true;
        focus_removed_window = true;
        drag_into_group = 1;
        merge_groups_on_drag = true;
        merge_groups_on_groupbar = true;
        merge_floated_into_tiled_on_groupbar = false;
        group_on_movetoworkspace = false;
        "col.border_active" = "$secondary";
        "col.border_inactive" = "$background";
        "col.border_locked_active" = "$secondary";
        "col.border_locked_inactive" = "$background";
      };

      dwindle = {
        force_split = 0;
        special_scale_factor = 1.0;
        split_width_multiplier = 1.0;
        use_active_for_splits = true;
        pseudotile = "yes";
        preserve_split = "yes";
      };

      cursor = {
        inactive_timeout = 5;
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

      "$mainMod" = "SUPER";

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioNext, exec, playerctl next"
      ];

      bindle = [
        ", XF86MonBrightnessUp, exec, brightnessctl set '600+'"
        ", XF86MonBrightnessDown, exec, brightnessctl set '600-'"
        "$mainMod, XF86AudioRaiseVolume, exec, brightnessctl set '600+'"
        "$mainMod, XF86AudioLowerVolume, exec, brightnessctl set '600-'"
      ];

      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
      ];

      bind = [
        "$mainMod, d, killactive,"
        "$mainMod, t, exec, kitty"
        "$mainMod, Return, exec, kitty"
        "$mainMod, z, exec, zen"
        "$mainMod, v, exec, codium"
        "$mainMod, e, exec, nautilus"

        "$mainMod, s, exec, screenshot"
        "$mainMod SHIFT, s, exec, screenshot --full"

        "$mainMod, f, fullscreen, 0"
        "$mainMod SHIFT, f, fullscreen, 1"

        "$mainMod, a, togglefloating,"

        "$mainMod SHIFT, q, togglegroup"
        "$mainMod, q, changegroupactive"

        "$mainMod, w, togglespecialworkspace"
        "$mainMod SHIFT, w, movetoworkspace, special"

        "$mainMod SHIFT, m, exit,"

        "$mainMod, Space, exec, ags toggle launcher"
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
  };
}
