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

    # Live mode runs the shell from the checkout, whose compiled shaders are not
    # tracked, and Quickshell reloads by itself on every save. A running shell
    # keeps the config it started on, though, so after a rebuild it is stopped
    # and ShojiWM's "shell" service starts it again on the new one: no logout.
    home.activation.hyaloShell = lib.hm.dag.entryAfter ["writeBoundary" "hyaloShojiwm"] (
      lib.optionalString cfg.liveConfig ''
        run ${pkgs.hyalo-shell}/bin/hyalo-shell-build-shaders ${lib.escapeShellArg "${osConfig.hyalo.flakePath}/config/shell"} >/dev/null
      ''
      + ''
        export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
        run ${lib.getExe pkgs.quickshell} kill -c hyalo >/dev/null 2>&1 || true
      ''
    );

    xdg.configFile."hyalo/dock.json".text = builtins.toJSON {pinned = hcfg.dock.pinned;};

    xdg.dataFile."hyalo/wallpaper" = lib.mkIf (hcfg.wallpaper != null) {
      source = hcfg.wallpaper;
    };
  };
}
