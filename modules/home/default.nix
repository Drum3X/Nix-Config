{...}: {
  imports = [
    ./desktop/mime.nix

    ./theme/cursor.nix

    ./apps/browsers.nix
    ./apps/media.nix

    ./terminal/cli.nix
    ./terminal/git.nix
    ./terminal/helix.nix
  ];

  programs.home-manager.enable = true;
}
