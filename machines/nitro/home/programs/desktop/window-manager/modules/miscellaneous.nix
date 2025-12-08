{config, ...}: {
  programs.niri.settings = {
    environment = config.home.sessionVariables;

    overview = {
      zoom = 0.8;

      workspace-shadow.enable = false;
    };
  };
}
