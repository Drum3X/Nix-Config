{...}: {
  imports = [
    ./disko.nix
    ./hardware.nix
  ];

  my = {
    user = "drum3x";
    flakePath = "/home/drum3x/Config";

    desktop.enable = true;

    hardware.nvidia = {
      enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };

    network = {
      dnscrypt.enable = false;
      f-dpi.enable = true;
      zapret.enable = false;
    };
  };

  # Set once at install time; do not bump it on upgrades.
  system.stateVersion = "26.05";
}
