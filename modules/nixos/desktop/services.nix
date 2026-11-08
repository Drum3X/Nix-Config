{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.my.desktop.enable {
    # GTK apps (Chrome, OBS) keep their settings in dconf.
    programs.dconf.enable = true;
  };
}
