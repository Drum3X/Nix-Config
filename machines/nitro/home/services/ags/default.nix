{ config, ... }:
{
  systemd.user.services.ags = {
    Unit = {
      Description = "Drumshell";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session-pre.target" ];
    };

    Service = {
      ExecStart = "${config.programs.ags.finalPackage}/bin/ags run --gtk4";
      Restart = "on-failure";
      KillMode = "mixed";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
