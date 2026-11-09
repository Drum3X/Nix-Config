{pkgs, ...}: let
  # Crow reads the selected text from the primary selection, which Wayland
  # hands only to the focused window, so from the tray its shortcuts get
  # nothing. Under XWayland KWin passes the selection on.
  crow = pkgs.symlinkJoin {
    name = "crow-translate-xwayland";
    paths = [pkgs.crow-translate];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/crow --set QT_QPA_PLATFORM xcb
      # The menu entry runs the store path of the unwrapped binary.
      desktop=share/applications/org.kde.CrowTranslate.desktop
      rm $out/$desktop
      sed 's|^Exec=${pkgs.crow-translate}/bin/crow|Exec=crow|' \
        ${pkgs.crow-translate}/$desktop > $out/$desktop
    '';
  };
in {
  # KDE's translator: Google, Bing and Yandex, OCR, global shortcuts.
  home.packages = [crow];
}
