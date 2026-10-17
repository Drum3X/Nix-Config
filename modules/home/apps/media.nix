{pkgs, ...}: {
  programs.obs-studio.enable = true;

  home.packages = with pkgs; [
    mpv
    pavucontrol
  ];
}
