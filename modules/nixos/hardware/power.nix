{pkgs, ...}: {
  services = {
    upower.enable = true;
    power-profiles-daemon.enable = true;
    thermald.enable = true;

    # Lid closed -> suspend; the shell locks before sleep.
    logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandlePowerKey = "suspend";
    };

    # Lets the video group write the backlight (brightnessctl).
    udev.packages = [pkgs.brightnessctl];
  };
}
