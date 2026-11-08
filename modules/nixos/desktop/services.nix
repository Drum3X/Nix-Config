{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.my.desktop.enable {
    programs.dconf.enable = true;

    services = {
      gvfs.enable = true;
      udisks2.enable = true;
      gnome = {
        gnome-keyring.enable = true;
        sushi.enable = true;
      };
    };
  };
}
