{ ... }:
{
  services.gnome = {
    evolution-data-server.enable = true;
    glib-networking.enable = true;
    gnome-keyring.enable = true;
    gnome-online-accounts.enable = true;
    localsearch.enable = true;
    tinysparql.enable = true;
  };
}
