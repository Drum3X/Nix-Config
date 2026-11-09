{...}: let
  browser = "google-chrome.desktop";
in {
  xdg = {
    # Apps rewrite mimeapps.list; the config wins, without a backup that
    # would block the next activation.
    configFile."mimeapps.list".force = true;

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
        # Claude Code sign-in links (claude-cli://); it writes this entry
        # itself otherwise.
        "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
      };
    };
  };

  home.sessionVariables = {
    BROWSER = "google-chrome-stable";
    TERMINAL = "konsole";
    FILE_MANAGER = "dolphin";
  };
}
