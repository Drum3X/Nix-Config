{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;

    extraCompatPackages = [
      pkgs.proton-ge-bin
    ];
  };
}
