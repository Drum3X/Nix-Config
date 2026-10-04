{lib, ...}: let
  customBinds = [
    {
      name = "Terminal";
      command = "ghostty";
      binding = "<Super>Return";
    }
    {
      name = "Terminal (alt)";
      command = "ghostty";
      binding = "<Super>t";
    }
    {
      name = "Browser";
      command = "chromium";
      binding = "<Super>q";
    }
    {
      name = "Files";
      command = "nautilus";
      binding = "<Super>e";
    }
  ];

  customPath = i: "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${toString i}";

  workspaces = lib.range 1 9;

  workspaceBinds = lib.listToAttrs (lib.concatMap (i: let
      n = toString i;
    in [
      (lib.nameValuePair "switch-to-workspace-${n}" ["<Super>${n}"])
      (lib.nameValuePair "move-to-workspace-${n}" ["<Super><Control>${n}"])
    ])
    workspaces);

  freeAppBinds = lib.listToAttrs (map (i: lib.nameValuePair "switch-to-application-${toString i}" []) workspaces);
in {
  dconf.settings =
    {
      "org/gnome/desktop/wm/keybindings" =
        {
          close = ["<Super>d"];
          toggle-maximized = ["<Super>f"];
          toggle-fullscreen = ["<Super><Shift>f"];

          switch-input-source = ["<Super>space" "<Shift>Alt_L"];
          switch-input-source-backward = ["<Super><Shift>space" "<Alt>Shift_L"];
        }
        // workspaceBinds;

      "org/gnome/shell/keybindings" =
        {
          show-screenshot-ui = ["Print" "<Super><Shift>s"];
        }
        // freeAppBinds;

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = lib.imap0 (i: _: "/${customPath i}/") customBinds;
      };
    }
    // lib.listToAttrs (lib.imap0 (i: bind: lib.nameValuePair (customPath i) bind) customBinds);
}
