{config, ...}: {
  programs.niri.settings = {
    environment = {
      QT_QPA_PLATFORM = "wayland";
    };

    cursor = {
      theme = config.home.pointerCursor.name;
      size = config.home.pointerCursor.size;

      hide-when-typing = true;
      hide-after-inactive-ms = 3000;
    };

    overview = {
      zoom = 0.8;

      workspace-shadow.enable = false;
    };
  };
}
