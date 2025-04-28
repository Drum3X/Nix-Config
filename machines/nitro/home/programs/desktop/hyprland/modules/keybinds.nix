{ ... }:
{
  wayland.windowManager.hyprland.settings = {
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
      "$mainMod, t, exec, ghostty"
      "$mainMod, Return, exec, ghostty"
      "$mainMod, z, exec, zen"
      "$mainMod, v, exec, code"
      "$mainMod, e, exec, nautilus"

      "$mainMod, s, exec, screenshot"
      "$mainMod SHIFT, s, exec, screenshot --full"

      "$mainMod, f, fullscreen, 0"
      "$mainMod SHIFT, f, fullscreen, 1"

      "$mainMod, Space, togglefloating,"

      "$mainMod SHIFT, q, togglegroup"
      "$mainMod, q, changegroupactive"

      "$mainMod, w, togglespecialworkspace"
      "$mainMod SHIFT, w, movetoworkspace, special"

      "$mainMod SHIFT, m, exit,"

      "$mainMod, a, exec, rofi -show drun"
      "$mainMod SHIFT, r, exec, ags quit & ags run --gtk4"

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
}
