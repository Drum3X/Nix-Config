{pkgs, ...}: {
  # The COSMIC module installs its own fonts (Open Sans, Noto, Fira); these only
  # add scripts and emoji they do not cover.
  fonts = {
    packages = with pkgs; [
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];

    # causes more issues than it solves
    enableDefaultPackages = false;

    # COSMIC's own defaults, so apps that ask fontconfig match COSMIC apps.
    fontconfig.defaultFonts = {
      serif = ["Noto Serif"];
      sansSerif = ["Open Sans"];
      monospace = ["Noto Sans Mono"];
      emoji = ["Noto Color Emoji"];
    };
  };
}
