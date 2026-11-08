{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra
    btop
    claude-code
    fastfetch
    fd
    nil
    ripgrep
    unzip
    wl-clipboard # wl-copy/wl-paste: CLI tools (gh, claude) copy through it on Wayland
  ];

  programs = {
    bash.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
