{ lib, ... }:
{
  networking = {
    hostName = "nitro";
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
  };
}
