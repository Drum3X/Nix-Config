{...}: {
  imports = [
    ./disko.nix
    ./hardware.nix
  ];

  hyalo = {
    user = "drum3x";
    flakePath = "/home/drum3x/nix-config";

    desktop = {
      enable = true;
      # Point ~/.config/shojiwm and the shell at the checkout in flakePath so the
      # design can be iterated on with hot reload, without a rebuild per change.
      liveConfig = false;
    };

    hardware.nvidia = {
      enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };

    network = {
      dnscrypt.enable = false;
      zapret.enable = false;
    };
  };

  # Set once at install time; do not bump it on upgrades.
  system.stateVersion = "26.05";
}
