{...}: let
  browser = "google-chrome.desktop";
in {
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };

    # Everything else opens in Plasma's own apps.
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/about" = browser;
        "inode/directory" = "org.kde.dolphin.desktop";
        "text/plain" = "org.kde.kate.desktop";
        "application/pdf" = "org.kde.okular.desktop";
      };
    };
  };

  home.sessionVariables = {
    BROWSER = "google-chrome-stable";
    TERMINAL = "konsole";
    FILE_MANAGER = "dolphin";
  };
}
