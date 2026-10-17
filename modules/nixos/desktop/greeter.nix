{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.hyalo.desktop;
  xkb = config.services.xserver.xkb;

  # cage runs one fullscreen client and nothing else, which is all a greeter
  # needs. The glass on this screen is drawn by the greeter itself from the
  # wallpaper it owns, so it does not depend on ShojiWM's shaders.
  greeter = pkgs.writeShellScript "hyalo-greeter-session" ''
    export XKB_DEFAULT_LAYOUT=${lib.escapeShellArg xkb.layout}
    export XKB_DEFAULT_OPTIONS=${lib.escapeShellArg xkb.options}
    export XDG_CACHE_HOME=/var/cache/hyalo-greeter
    export XDG_STATE_HOME=/var/cache/hyalo-greeter/state
    export HYALO_GREETER_USER=${lib.escapeShellArg config.hyalo.user}
    export HYALO_SESSION_COMMAND=/run/current-system/sw/bin/hyalo-session
    exec ${lib.getExe pkgs.cage} -s -m last -- ${pkgs.hyalo-shell}/bin/hyalo-greeter
  '';
in {
  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings.default_session = {
        user = "greeter";
        command = "${greeter}";
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/cache/hyalo-greeter 0750 greeter greeter -"
    ];

    # Unlock the login keyring with the password typed into the greeter.
    security.pam.services.greetd.enableGnomeKeyring = true;
  };
}
