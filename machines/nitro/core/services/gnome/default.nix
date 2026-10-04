{...}: {
  services.desktopManager.gnome.enable = true;

  services.gnome = {
    sushi.enable = true;
    gnome-keyring.enable = true;
  };
}
