{ pkgs, outputs, ... }:
{
  imports = [
    ./modules
    ./programs
    ./theme
  ];

  home.stateVersion = "24.11";
}
