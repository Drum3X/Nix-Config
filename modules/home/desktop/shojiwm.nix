{
  config,
  lib,
  osConfig,
  ...
}: let
  cfg = osConfig.hyalo.desktop;
  source = ../../../config/shojiwm;
  checkout = "${osConfig.hyalo.flakePath}/config/shojiwm";
  target = "${config.xdg.configHome}/shojiwm";
in {
  # ShojiWM's config directory has to stay writable: shojiwm-init-config
  # rewrites package.json and tsconfig.json and links node_modules/shoji_wm on
  # every run, and the TypeScript runtime resolves imports from the real path
  # of each file. So the config is copied (or, in live mode, the whole
  # directory is linked to the checkout) rather than symlinked file by file.
  config = lib.mkIf cfg.enable {
    home.activation.hyaloShojiwm = lib.hm.dag.entryAfter ["writeBoundary"] (''
        target=${lib.escapeShellArg target}
      ''
      + (
        if cfg.liveConfig
        then ''
          checkout=${lib.escapeShellArg checkout}
          if [ ! -d "$checkout" ]; then
            warnEcho "hyalo: $checkout does not exist; clone the flake there for live config"
          fi
          if [ -e "$target" ] && [ ! -L "$target" ]; then
            run mv "$target" "$target.hm-backup"
          fi
          run ln -sfn "$checkout" "$target"
        ''
        else ''
          if [ -L "$target" ]; then
            run rm "$target"
          fi
          run mkdir -p "$target"
          run rm -rf "$target/src" "$target/assets"
          run cp -r --no-preserve=mode ${source}/src ${source}/assets "$target/"
        ''
      )
      + ''
        init=/run/current-system/sw/bin/shojiwm-init-config
        if [ -x "$init" ]; then
          run env XDG_CONFIG_HOME=${lib.escapeShellArg config.xdg.configHome} "$init" >/dev/null
        fi

        # Apply the new config to a running session instead of needing a logout.
        export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
        if [ -x /run/current-system/sw/bin/shoji_wm ]; then
          run timeout 5 /run/current-system/sw/bin/shoji_wm --reload >/dev/null 2>&1 || true
        fi
      '');
  };
}
