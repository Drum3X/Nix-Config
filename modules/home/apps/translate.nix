{pkgs, ...}: let
  # Crow reads the selected text from the primary selection, which Wayland
  # hands only to the focused window, so from the tray its shortcuts get
  # nothing. It runs under XWayland instead, and its selection shortcuts first
  # copy the Wayland selection into the X one: KWin syncs the two only while
  # an X window has focus.
  selection = pkgs.writeShellScript "crow-selection" ''
    xclip=${pkgs.xclip}/bin/xclip
    text=$(${pkgs.wl-clipboard}/bin/wl-paste --primary --no-newline)
    printf %s "$text" | $xclip -selection primary
    # xclip takes the selection from a forked child: wait for it (up to 1s),
    # or Crow may read the selection before it is there.
    for _ in $(seq 20); do
      [ "$($xclip -o -selection primary 2>/dev/null)" = "$text" ] && break
      sleep 0.05
    done
    exec ${pkgs.qt6.qttools}/bin/qdbus org.kde.CrowTranslate \
      /org/kde/CrowTranslate/MainWindow "$1"
  '';
  crow = pkgs.symlinkJoin {
    name = "crow-translate-xwayland";
    paths = [pkgs.crow-translate];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      # Crow's single-instance lock (shared memory and a socket, named after
      # the app and user) outlives it when it is killed, even by SIGTERM at
      # logout; the next Crow then takes it for a running one and quits
      # silently. Clear it when no Crow is running.
      wrapProgram $out/bin/crow --set QT_QPA_PLATFORM xcb --run '
        if ! ${pkgs.procps}/bin/pgrep -u "$(id -u)" -x .crow-wrapped >/dev/null; then
          lock=DGmXV0fRZmWN3QniUGcRsBfQODhkBnRHyz1MgaYC8iY=
          rm -f "/dev/shm/$lock" "/dev/shm/sem.$lock" "/tmp/$lock"
        fi'
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
