{...}: let
  tr = "tr_TR.UTF-8";
in {
  time.timeZone = "Europe/Istanbul";

  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = tr;
      LC_IDENTIFICATION = tr;
      LC_MEASUREMENT = tr;
      LC_MONETARY = tr;
      LC_NAME = tr;
      LC_NUMERIC = tr;
      LC_PAPER = tr;
      LC_TELEPHONE = tr;
      LC_TIME = tr;
    };
  };

  # Also what cage (the greeter's compositor) reads through XKB_DEFAULT_*.
  services.xserver.xkb = {
    layout = "tr,us";
    options = "grp:alt_shift_toggle";
  };

  console.useXkbConfig = true;
}
