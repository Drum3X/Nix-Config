{...}: {
  imports = [../../modules/home];

  home = {
    username = "drum3x";
    homeDirectory = "/home/drum3x";
    stateVersion = "26.05";
  };

  programs.git.settings.user = {
    name = "Drum3X";
    email = "drum3x@tutamail.com";
  };

  # Pinned apps in the dock, by desktop entry id.
  hyalo.dock.pinned = [
    "org.gnome.Nautilus"
    "vivaldi-stable"
    "com.mitchellh.ghostty"
    "code"
    "com.obsproject.Studio"
  ];
}
