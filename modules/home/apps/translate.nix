{pkgs, ...}: let
  # Crow reads the selected text from the primary selection, which Wayland
  # hands only to the focused window, so from the tray its shortcuts get
  # nothing. It runs under XWayland instead, and its selection shortcuts first
  # copy the Wayland selection into the X one: KWin syncs the two only while
  # an X window has focus.
  selection = pkgs.writeShellScript "crow-selection" ''
    ${pkgs.wl-clipboard}/bin/wl-paste --primary --no-newline \
      | ${pkgs.xclip}/bin/xclip -selection primary
    exec ${pkgs.qt6.qttools}/bin/qdbus org.kde.CrowTranslate \
      /org/kde/CrowTranslate/MainWindow "$1"
  '';
  crow = pkgs.symlinkJoin {
    name = "crow-translate-xwayland";
    paths = [pkgs.crow-translate];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/crow --set QT_QPA_PLATFORM xcb
      # The menu entry runs the store path of the unwrapped binary, and the
      # shortcut actions call Crow over D-Bus directly.
      desktop=share/applications/org.kde.CrowTranslate.desktop
      rm $out/$desktop
      sed -E \
        -e 's|^Exec=${pkgs.crow-translate}/bin/crow|Exec=crow|' \
        -e 's|^Exec=.*/qdbus org.kde.CrowTranslate /org/kde/CrowTranslate/MainWindow (translateSelection\|speakSelection\|speakTranslatedSelection\|copyTranslatedSelection)$|Exec=${selection} \1|' \
        ${pkgs.crow-translate}/$desktop > $out/$desktop
    '';
  };
in {
  # KDE's translator: Google, Bing and Yandex, OCR, global shortcuts.
  home.packages = [crow];
}
