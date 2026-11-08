{
  config,
  inputs,
  lib,
  ...
}: {
  # F-Dpi's own module: the app and its setuid core (security.wrappers).
  imports = [inputs.f-dpi.nixosModules.default];

  config = lib.mkIf config.my.network.f-dpi.enable {
    programs.f-dpi.enable = true;
  };
}
