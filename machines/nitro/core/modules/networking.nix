{ pkgs, ... }:
{
  networking = {
    hostName = "nitro";
    networkmanager.enable = true;
  };

  environment.systemPackages = with pkgs; [ networkmanagerapplet ];
}
