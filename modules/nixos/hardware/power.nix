{ ... }: {
  # Plasma turns on upower and power-profiles-daemon, and PowerDevil handles
  # the lid, the backlight and, inside the session, the power key.
  services = {
    thermald.enable = true;

    # At the SDDM screen, before PowerDevil runs.
    logind.settings.Login.HandlePowerKey = "suspend";
  };
}
