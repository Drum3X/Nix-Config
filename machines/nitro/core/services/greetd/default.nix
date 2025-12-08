{pkgs, ...}: {
  services.greetd = let
    session = {
      command = "${pkgs.niri}/bin/niri-session";
      user = "drum3x";
    };
  in {
    enable = true;
    settings = {
      terminal.vt = 1;
      default_session = session;
      initial_session = session;
    };
  };
}
