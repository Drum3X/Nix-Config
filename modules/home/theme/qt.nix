{
  config,
  lib,
  pkgs,
  ...
}: let
  KvLibadwaita = pkgs.fetchFromGitHub {
    owner = "GabePoel";
    repo = "KvLibadwaita";
    rev = "87c1ef9f44ec48855fd09ddab041007277e30e37";
    hash = "sha256-K/2FYOtX0RzwdcGyeurLXAh3j8ohxMrH2OWldqVoLwo=";
    sparseCheckout = ["src"];
  };

  qtctConf = {
    Appearance = {
      custom_palette = false;
      icon_theme = config.gtk.iconTheme.name;
      standard_dialogs = "xdgdesktopportal";
      style = "kvantum";
    };
  };

  defaultFont = "${config.gtk.font.name},${toString config.gtk.font.size}";
in {
  qt = {
    enable = true;
    platformTheme.name = "qtct";
  };

  home.packages = [
    pkgs.qt6Packages.qtstyleplugin-kvantum
    pkgs.qt6Packages.qt6ct
    pkgs.libsForQt5.qtstyleplugin-kvantum
    pkgs.libsForQt5.qt5ct
  ];

  # Kvantum's own kvantum.kvconfig is left writable on purpose: darkman
  # rewrites it to switch between KvLibadwaita and KvLibadwaitaDark.
  xdg.configFile = {
    # One folder holds both variants (KvLibadwaita.kvconfig, KvLibadwaitaDark.kvconfig).
    "Kvantum/KvLibadwaita".source = "${KvLibadwaita}/src/KvLibadwaita";

    "qt5ct/qt5ct.conf".text = let
      font = ''"${defaultFont},-1,5,50,0,0,0,0,0"'';
    in
      lib.generators.toINI {} (qtctConf
        // {
          Fonts = {
            fixed = font;
            general = font;
          };
        });

    "qt6ct/qt6ct.conf".text = let
      font = ''"${defaultFont},-1,5,400,0,0,0,0,0,0,0,0,0,0,1,Regular"'';
    in
      lib.generators.toINI {} (qtctConf
        // {
          Fonts = {
            fixed = font;
            general = font;
          };
        });
  };
}
