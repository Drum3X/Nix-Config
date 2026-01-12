{config, ...}: {
  programs.niri.settings.binds = with config.lib.niri.actions; let
  in {
    # Window & Workspace bindings
    "Mod+D".action = close-window;
    "Mod+Tab".action.toggle-overview = {};
    "super+V".action = toggle-window-floating;
    "Mod+Shift+P".action.power-off-monitors = {};

    "Mod+Left".action.focus-column-left = {};
    "Mod+Down".action.focus-window-down = {};
    "Mod+Up".action.focus-window-up = {};
    "Mod+Right".action.focus-column-right = {};
    "Mod+H".action.focus-column-left = {};
    "Mod+J".action.focus-window-down = {};
    "Mod+K".action.focus-window-up = {};
    "Mod+L".action.focus-column-right = {};

    "Mod+Shift+Left".action.move-column-left = {};
    "Mod+Shift+Down".action.move-window-down = {};
    "Mod+Shift+Up".action.move-window-up = {};
    "Mod+Shift+Right".action.move-column-right = {};
    "Mod+Shift+H".action.move-column-left = {};
    "Mod+Shift+J".action.move-window-down = {};
    "Mod+Shift+K".action.move-window-up = {};
    "Mod+Shift+L".action.move-column-right = {};

    "Mod+Ctrl+Down".action.focus-workspace-down = {};
    "Mod+Ctrl+Up".action.focus-workspace-up = {};
    "Mod+Ctrl+J".action.focus-workspace-down = {};
    "Mod+Ctrl+K".action.focus-workspace-up = {};

    "Mod+WheelScrollDown".action.focus-column-right = {};
    "Mod+WheelScrollUp".action.focus-column-left = {};
    "Mod+Shift+WheelScrollDown".action.move-column-right = {};
    "Mod+Shift+WheelScrollUp".action.move-column-left = {};
    "Mod+Ctrl+WheelScrollDown".action.focus-workspace-down = {};
    "Mod+Ctrl+WheelScrollUp".action.focus-workspace-up = {};
    "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-to-workspace-down = {};
    "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-to-workspace-up = {};

    "Mod+1".action.focus-workspace = 1;
    "Mod+2".action.focus-workspace = 2;
    "Mod+3".action.focus-workspace = 3;
    "Mod+4".action.focus-workspace = 4;
    "Mod+5".action.focus-workspace = 5;
    "Mod+6".action.focus-workspace = 6;
    "Mod+7".action.focus-workspace = 7;
    "Mod+8".action.focus-workspace = 8;
    "Mod+9".action.focus-workspace = 9;
    "Mod+Ctrl+1".action.move-column-to-workspace = 1;
    "Mod+Ctrl+2".action.move-column-to-workspace = 2;
    "Mod+Ctrl+3".action.move-column-to-workspace = 3;
    "Mod+Ctrl+4".action.move-column-to-workspace = 4;
    "Mod+Ctrl+5".action.move-column-to-workspace = 5;
    "Mod+Ctrl+6".action.move-column-to-workspace = 6;
    "Mod+Ctrl+7".action.move-column-to-workspace = 7;
    "Mod+Ctrl+8".action.move-column-to-workspace = 8;
    "Mod+Ctrl+9".action.move-column-to-workspace = 9;

    "Mod+WheelScrollRight".action.focus-column-right = {};
    "Mod+WheelScrollLeft".action.focus-column-left = {};
    "Mod+Ctrl+WheelScrollRight".action.move-column-right = {};
    "Mod+Ctrl+WheelScrollLeft".action.move-column-left = {};

    "Mod+Shift+C".action.consume-window-into-column = {};
    "Mod+Shift+V".action.expel-window-from-column = {};

    "Mod+Shift+X".action.set-column-width = "+10%";
    "Mod+Shift+Z".action.set-column-width = "-10%";
    "Mod+Ctrl+X".action.set-window-height = "+10%";
    "Mod+Ctrl+Z".action.set-window-height = "-10%";

    "Mod+R".action.switch-preset-column-width = {};
    "Mod+Shift+R".action.reset-window-height = {};
    "Mod+F".action.maximize-column = {};
    "Mod+Shift+F".action.fullscreen-window = {};
    "Mod+G".action.center-column = {};

    # Screenshot Bindings
    "Print".action.screenshot = {};
    "Shift+Print".action.screenshot-screen = {};
    "Ctrl+Print".action.screenshot-window = {};

    "Mod+S".action.screenshot = {};
    "Mod+Shift+S".action.screenshot-screen = {};
    "Mod+Ctrl+S".action.screenshot-window = {};

    # App Bindings
    "Mod+Return".action = spawn config.home.sessionVariables.TERMINAL;
    "Mod+T".action = spawn config.home.sessionVariables.TERMINAL;
    "Mod+A".action = spawn config.home.sessionVariables.LAUNCHER;
    "Mod+Q".action = spawn config.home.sessionVariables.BROWSER;
    "Mod+Space".action.spawn = ["qs" "-c" "niri-caelestia-shell" "ipc" "call" "drawers" "toggle" "launcher"];

    # XF86
    "XF86AudioRaiseVolume" = {
      allow-when-locked = true;
      action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"];
    };
    "XF86AudioLowerVolume" = {
      allow-when-locked = true;
      action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"];
    };
    "XF86AudioMute" = {
      allow-when-locked = true;
      action.spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];
    };
    "XF86AudioMicMute" = {
      allow-when-locked = true;
      action.spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"];
    };
    "XF86AudioPlay" = {
      allow-when-locked = true;
      action.spawn = ["playerctl" "play-pause"];
    };
    "XF86AudioNext" = {
      allow-when-locked = true;
      action.spawn = ["playerctl" "next"];
    };
    "XF86AudioPrev" = {
      allow-when-locked = true;
      action.spawn = ["playerctl" "prev"];
    };
    "XF86MonBrightnessUp" = {
      allow-when-locked = true;
      action.spawn = [""];
    };
    "XF86MonBrightnessDown" = {
      allow-when-locked = true;
      action.spawn = [""];
    };
  };
}
