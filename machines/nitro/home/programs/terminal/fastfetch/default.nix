{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fastfetch
  ];

  home.file.".config/fastfetch" = {
    source = ./config;
    recursive = true;
  };
}
