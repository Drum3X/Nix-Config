{
  inputs,
  pkgs,
  ...
}: {
  home.sessionVariables = {
    LAUNCHER = "${inputs.vicinae.packages."${pkgs.system}".default}/bin/vicinae";
    BROWSER = "${inputs.zen-browser.packages."${pkgs.system}".beta}/bin/zen";
    TERMINAL = "${pkgs.ghostty}/bin/ghostty";
    FILE_MANAGER = "${pkgs.nautilus}/bin/nautilus";

    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    NIXOS_OZONE_WL = "1";
  };
}
