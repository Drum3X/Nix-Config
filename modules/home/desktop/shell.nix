{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = osConfig.hyalo.desktop;
  hcfg = config.hyalo;
in {
  options.hyalo = {
    dock.pinned = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Desktop entry ids pinned to the dock, left to right.";
    };

    wallpaper = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Wallpaper image; null uses the one bundled with hyalo-shell.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      hyalo-shell
      darkman
      glib # gio trash
    ];

    # `quickshell -c hyalo` (what the hyalo-shell wrapper runs) loads this.
    xdg.configFile."quickshell/hyalo".source =
      if cfg.liveConfig
      then config.lib.file.mkOutOfStoreSymlink "${osConfig.hyalo.flakePath}/config/shell"
      else "${pkgs.hyalo-shell}/share/hyalo-shell";

    xdg.configFile."hyalo/dock.json".text = builtins.toJSON {pinned = hcfg.dock.pinned;};

    xdg.dataFile."hyalo/wallpaper" = lib.mkIf (hcfg.wallpaper != null) {
      source = hcfg.wallpaper;
    };
  };
}
