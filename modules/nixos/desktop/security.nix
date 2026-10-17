{
  config,
  lib,
  ...
}: {
  security.polkit.enable = true;

  # The shell's lock screen authenticates against this service.
  security.pam.services.hyalo-lock = lib.mkIf config.hyalo.desktop.enable {};
}
