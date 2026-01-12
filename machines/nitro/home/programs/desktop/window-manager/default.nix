{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.niri.homeModules.niri

    ./modules
  ];

  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };
}
