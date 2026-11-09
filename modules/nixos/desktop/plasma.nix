{
  config,
  lib,
  pkgs,
  ...
}: let
  cursor = "Bibata-Modern-Classic";
in {
  config = lib.mkIf config.my.desktop.enable {
    # Plasma 6 with its default apps (Konsole, Dolphin, Kate, Ark, Gwenview,
    # Okular, Spectacle, Elisa), fonts, theme and KWallet; SDDM on Wayland.
    services.desktopManager.plasma6.enable = true;
    # Plasma turns on KDE PIM (KMail, Kontact, Merkuro) by default. Its
    # Akonadi server (MariaDB plus a dozen agents) starts with the panel and
    # stalls it; mail is Thunderbird here.
    programs.kde-pim.enable = false;
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      settings.Theme.CursorTheme = cursor;
    };

    # The Bibata cursor instead of Breeze, in SDDM and as Plasma's default
    # (System Settings can still change it). GTK and X apps get it from
    # Home Manager (modules/home/theme/cursor.nix).
    environment.systemPackages = [pkgs.bibata-cursors];
    environment.etc."xdg/kcminputrc".text = ''
      [Mouse]
      cursorTheme=${cursor}
      cursorSize=24
    '';

    # Writes the files Chrome reads from /etc/opt/chrome (no Chromium
    # installed): the Plasma module only sets the Plasma Browser Integration
    # host up, and NixOS links it there only with this on.
    programs.chromium.enable = true;

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      # Spectacle's OCR links Tesseract without any language data; point it
      # at English and Turkish.
      TESSDATA_PREFIX = "${pkgs.tesseract.override {enableLanguages = ["eng" "tur"];}}/share/tessdata";
    };
  };
}
