{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.my.desktop.enable {
    # Plasma 6 with its default apps (Konsole, Dolphin, Kate, Ark, Gwenview,
    # Okular, Spectacle, Elisa), fonts, theme and KWallet; SDDM on Wayland.
    services.desktopManager.plasma6.enable = true;
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
