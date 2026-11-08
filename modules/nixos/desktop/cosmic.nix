{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.my.desktop.enable {
    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;

    # Recommended by the COSMIC module: keeps the session responsive under load.
    services.system76-scheduler.enable = true;

    # Unlock the login keyring with the password typed into the greeter.
    security.pam.services.cosmic-greeter.enableGnomeKeyring = true;

    environment.systemPackages = with pkgs; [
      wl-clipboard
      xdg-utils
    ];

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
