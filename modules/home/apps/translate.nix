{pkgs, ...}: {
  # KDE's translator: Google, Bing and Yandex, OCR, global shortcuts.
  home.packages = [pkgs.crow-translate];
}
