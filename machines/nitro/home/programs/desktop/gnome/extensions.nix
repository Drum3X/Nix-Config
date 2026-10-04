{pkgs, ...}: {
  programs.gnome-shell = {
    enable = true;
    extensions = map (package: {inherit package;}) (with pkgs.gnomeExtensions; [
      appindicator
      blur-my-shell
      caffeine
      dash-to-dock
    ]);
  };

  dconf.settings."org/gnome/shell/extensions/dash-to-dock" = {
    hot-keys = false;
  };
}
