{...}: {
  imports = [
    ./desktop/mime.nix
    ./desktop/plasma.nix

    ./theme/cursor.nix

    ./apps/browsers.nix
    ./apps/passwords.nix
    ./apps/media.nix
    ./apps/antigravity.nix
    ./apps/mail.nix
    ./apps/chat.nix

    ./terminal/cli.nix
    ./terminal/git.nix
    ./terminal/helix.nix
  ];

  programs.home-manager.enable = true;
}
