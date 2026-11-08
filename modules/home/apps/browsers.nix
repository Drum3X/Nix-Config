{pkgs, ...}: {
  home.packages = [
    (pkgs.google-chrome.override {
      # Wayland-native.
      commandLineArgs = "--ozone-platform-hint=auto";
    })
  ];
}
