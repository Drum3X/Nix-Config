{ pkgs, ... }:
{
  systemd.user.services.swww = {
    Unit = {
      Description = "Wallpaper Service";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.swww}/bin/swww-daemon";
      Restart = "on-failure";
      KillMode = "mixed";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
