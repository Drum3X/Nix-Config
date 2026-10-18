{
  lib,
  stdenvNoCC,
  makeWrapper,
  writeShellScriptBin,
  quickshell,
  qt6,
}: let
  src = lib.fileset.toSource {
    root = ../../config/shell;
    fileset = lib.fileset.difference ../../config/shell (lib.fileset.fileFilter (file: file.hasExt "qsb") ../../config/shell);
  };

  qsb = "${qt6.qtshadertools}/bin/qsb";

  # Live config mode (hyalo.desktop.liveConfig): the shell runs straight from
  # the checkout, so its shaders are compiled there.
  build-shaders = writeShellScriptBin "hyalo-shell-build-shaders" ''
    set -eu
    dir="''${1:-$HOME/Config/config/shell}/shaders"
    for frag in "$dir"/*.frag; do
      ${qsb} --qt6 -o "$frag.qsb" "$frag"
    done
    echo "hyalo-shell: shaders built in $dir"
  '';
in
  stdenvNoCC.mkDerivation {
    pname = "hyalo-shell";
    version = "0.1.0";
    inherit src;

    nativeBuildInputs = [makeWrapper];

    buildPhase = ''
      runHook preBuild
      for frag in shaders/*.frag; do
        ${qsb} --qt6 -o "$frag.qsb" "$frag"
      done
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/hyalo-shell $out/bin
      cp -r . $out/share/hyalo-shell/

      # The desktop shell. It runs the config at ~/.config/quickshell/hyalo,
      # which Home Manager points at this package or at the checkout, so IPC
      # calls (`hyalo-shell ipc call ...`) reach whichever one is running.
      makeWrapper ${lib.getExe quickshell} $out/bin/hyalo-shell \
        --add-flags "-c hyalo"

      # The greeter, always from the store: the greeter user cannot read home.
      makeWrapper ${lib.getExe quickshell} $out/bin/hyalo-greeter \
        --add-flags "-p $out/share/hyalo-shell/greeter.qml"

      ln -s ${build-shaders}/bin/hyalo-shell-build-shaders $out/bin/

      runHook postInstall
    '';

    meta = {
      description = "Hyalo's Quickshell desktop shell and greeter (liquid glass, for ShojiWM)";
      license = lib.licenses.gpl3Plus;
      platforms = lib.platforms.linux;
      mainProgram = "hyalo-shell";
    };
  }
