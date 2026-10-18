{
  lib,
  osConfig,
  pkgs,
  ...
}: let
  # Every switch goes through here, whether darkman's sunset timer or the
  # shell's toggle (`darkman toggle`) triggered it.
  apply = mode: let
    dark = mode == "dark";
  in ''
    ${lib.getExe pkgs.dconf} write /org/gnome/desktop/interface/color-scheme "'${
      if dark
      then "prefer-dark"
      else "default"
    }'"
    ${lib.getExe pkgs.dconf} write /org/gnome/desktop/interface/gtk-theme "'${
      if dark
      then "adw-gtk3-dark"
      else "adw-gtk3"
    }'"
    ${lib.getExe pkgs.dconf} write /org/gnome/desktop/interface/icon-theme "'${
      if dark
      then "Colloid-Dark"
      else "Colloid-Light"
    }'"

    kvconfig="''${XDG_CONFIG_HOME:-$HOME/.config}/Kvantum/kvantum.kvconfig"
    mkdir -p "$(dirname "$kvconfig")"
    rm -f "$kvconfig"
    printf '[General]\ntheme=%s\n' ${
      if dark
      then "KvLibadwaitaDark"
      else "KvLibadwaita"
    } > "$kvconfig"

    # The shell may not be running (greeter, TTY); that is fine.
    ${pkgs.hyalo-shell}/bin/hyalo-shell ipc call theme set ${mode} >/dev/null 2>&1 || true
  '';
in {
  config = lib.mkIf osConfig.hyalo.desktop.enable {
    services.darkman = {
      enable = true;
      settings = {
        # Istanbul.
        lat = 41.01;
        lng = 28.97;
        usegeoclue = false;
      };
      darkModeScripts.hyalo = apply "dark";
      lightModeScripts.hyalo = apply "light";
    };
  };
}
