{ lib, ... }: {
  networking = {
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
  };
}
