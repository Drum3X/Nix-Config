{...}: {
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = ["SF Mono" "Symbols Nerd Font"];
      font-size = 11;
      # Follows the system color scheme that darkman switches.
      theme = "light:Adwaita,dark:Adwaita Dark";
      background-opacity = 0.92;
      window-padding-x = 10;
      window-padding-y = 8;
      window-decoration = "server";
      gtk-titlebar = false;
    };
  };
}
