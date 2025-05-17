{
  config,
  lib,
  ...
}:
{
  services.greetd =
    let
      session = {
        command = "${lib.getExe config.programs.uwsm.package} start hyprland-uwsm.desktop";
        user = "drum3x";
      };
    in
    {
      enable = true;
      settings = {
        terminal.vt = 1;
        default_session = session;
        initial_session = session;
      };
    };
}
