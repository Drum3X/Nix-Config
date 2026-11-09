{pkgs, ...}: {
  # Accounts and settings live in its own profile, set up in the app.
  home.packages = [pkgs.thunderbird];
  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/mailto" = "thunderbird.desktop";
    "message/rfc822" = "thunderbird.desktop";
  };
}
