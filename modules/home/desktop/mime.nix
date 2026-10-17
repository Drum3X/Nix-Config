{...}: let
  browser = "chromium-browser.desktop";
  files = "org.gnome.Nautilus.desktop";
in {
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/about" = browser;
        "application/pdf" = browser;
        "inode/directory" = files;
        "text/plain" = "code.desktop";
      };
    };
  };

  home.sessionVariables = {
    BROWSER = "chromium";
    TERMINAL = "ghostty";
    FILE_MANAGER = "nautilus";
  };
}
