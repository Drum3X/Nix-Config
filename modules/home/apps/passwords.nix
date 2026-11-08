{pkgs, ...}: {
  home.packages = [pkgs.bitwarden-desktop];

  # Not started at login. Bitwarden's own "Start automatically on login"
  # writes this file; owning it here keeps it off (Hidden = removed, in the
  # XDG autostart spec), whatever that setting says.
  xdg.configFile."autostart/bitwarden.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Bitwarden
    Hidden=true
  '';
}
