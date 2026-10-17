{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.hyalo.desktop;

  # greetd starts this as the user. It rebuilds the login environment greetd
  # does not provide, runs the compositor, and tears the session's user units
  # down again once it exits.
  hyalo-session = pkgs.writeShellScriptBin "hyalo-session" ''
    . /etc/profile
    hm_vars="/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
    if [ -r "$hm_vars" ]; then
      . "$hm_vars"
    fi

    export XDG_CURRENT_DESKTOP=ShojiWM
    export XDG_SESSION_DESKTOP=shojiwm
    export XDG_SESSION_TYPE=wayland

    shoji_wm --tty
    status=$?

    systemctl --user stop hyalo-session.target graphical-session.target
    exit "$status"
  '';
in {
  config = lib.mkIf cfg.enable {
    programs.shojiwm = {
      enable = true;
      # The user config is installed by Home Manager (modules/home/desktop/shojiwm.nix),
      # which also runs shojiwm-init-config after copying it.
      initConfig.enable = false;
    };

    environment.systemPackages =
      [hyalo-session]
      ++ (with pkgs; [
        brightnessctl
        cliphist
        grim
        libnotify
        playerctl
        slurp
        swappy
        wl-clipboard
        wireplumber
        xdg-utils
      ]);

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      # ShojiWM's module adds its ScreenCast backend and the GTK fallback;
      # this covers sessions that do not set XDG_CURRENT_DESKTOP.
      config.common.default = ["gtk"];
    };

    # Started by the compositor once WAYLAND_DISPLAY exists (see config/shojiwm/src/index.tsx);
    # everything that wants graphical-session.target follows it.
    systemd.user.targets.hyalo-session = {
      description = "Hyalo graphical session";
      bindsTo = ["graphical-session.target"];
      wants = ["graphical-session-pre.target"];
      after = ["graphical-session-pre.target"];
    };

    systemd.user.services.hyalo-polkit-agent = {
      description = "Polkit authentication agent";
      wantedBy = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
      };
    };

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    };
  };
}
