{...}: {
  imports = [
    ./desktop/mime.nix

    ./theme/cursor.nix

    ./apps/browsers.nix
    ./apps/files.nix
    ./apps/media.nix

    ./terminal/cli.nix
    ./terminal/ghostty.nix
    ./terminal/git.nix
    ./terminal/helix.nix
  ];

  programs.home-manager.enable = true;
}
