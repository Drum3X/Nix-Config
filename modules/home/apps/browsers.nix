{pkgs, ...}: {
  home.packages = [
    (pkgs.vivaldi.override {
      # Wayland-native, with the system's native-messaging hosts (password managers etc.).
      commandLineArgs = "--ozone-platform-hint=auto";
    })
  ];
}
