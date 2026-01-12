{
  inputs,
  lib,
  pkgs,
  ...
}: let
  quickshell = inputs.quickshell.packages."${pkgs.system}".default;
in {
  home = {
    packages = [
      quickshell
      pkgs.kdePackages.qtdeclarative
      pkgs.kdePackages.kirigami.unwrapped
    ];

    sessionVariables.QML2_IMPORT_PATH = lib.concatStringsSep ":" [
      "${quickshell}/lib/qt-6/qml"
      "${pkgs.kdePackages.qtdeclarative}/lib/qt-6/qml"
      "${pkgs.kdePackages.kirigami.unwrapped}/lib/qt-6/qml"
    ];
  };
}
