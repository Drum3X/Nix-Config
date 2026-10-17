{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra
    btop
    fastfetch
    fd
    nil
    ripgrep
    unzip
  ];

  programs = {
    bash.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
