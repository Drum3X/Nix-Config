{...}: {
  imports = [
    ./desktop/mime.nix

    ./theme/cursor.nix
    ./theme/gtk.nix
    ./theme/qt.nix

    ./apps/browsers.nix
    ./apps/files.nix
    ./apps/media.nix
    ./apps/vscode.nix

    ./terminal/cli.nix
    ./terminal/ghostty.nix
    ./terminal/git.nix
    ./terminal/helix.nix
  ];

  programs.home-manager.enable = true;
}
