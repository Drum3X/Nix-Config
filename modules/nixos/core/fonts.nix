{
  inputs,
  pkgs,
  ...
}: let
  apple = inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system};
in {
  fonts = {
    packages = with pkgs; [
      # macOS fonts: SF Pro (Text / Display / Rounded), SF Mono, New York
      apple.sf-pro
      apple.sf-mono
      apple.ny

      # icon fonts
      material-symbols
      nerd-fonts.symbols-only

      # coverage for scripts the Apple fonts above do not have
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji

      inter
      jetbrains-mono
    ];

    # causes more issues than it solves
    enableDefaultPackages = false;

    fontconfig.defaultFonts = {
      serif = ["New York"];
      sansSerif = ["SF Pro Text"];
      monospace = ["SF Mono" "Symbols Nerd Font"];
      emoji = ["Noto Color Emoji"];
    };
  };
}
