{...}: {
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = ["SF Mono" "Symbols Nerd Font"];
      font-size = 11;
      # Follows the system color scheme that darkman switches.
      theme = "light:Adwaita,dark:Adwaita Dark";
      # See-through enough to show the window glass behind it.
      background-opacity = 0.65;
      window-padding-x = 10;
      window-padding-y = 8;
      window-decoration = "server";
      gtk-titlebar = false;
    };
  };
}
