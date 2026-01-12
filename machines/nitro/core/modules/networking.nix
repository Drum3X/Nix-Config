{lib, ...}: {
  networking = {
    hostName = "nitro";
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;

    # nameservers = ["127.0.0.1" "::1"];
  };
}
