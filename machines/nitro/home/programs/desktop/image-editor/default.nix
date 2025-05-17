{ pkgs, ... }:
{
  home.packages = [
    (pkgs.gimp-with-plugins.override {
      plugins = with pkgs.gimpPlugins; [
        gmic
      ];
    })
  ];
}
