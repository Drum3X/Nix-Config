{pkgs, ...}: {
  # Plasma installs and picks its own fonts (Noto Sans, Hack); these only add
  # scripts and emoji Noto Sans does not cover.
  fonts = {
    packages = with pkgs; [
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];

    # causes more issues than it solves
    enableDefaultPackages = false;
  };
}
