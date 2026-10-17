{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.hyalo.network.dnscrypt.enable {
    services.dnscrypt-proxy = {
      enable = true;
      settings.listen_addresses = ["127.0.0.1:53" "[::1]:53"];
    };

    networking = {
      nameservers = ["127.0.0.1" "::1"];
      networkmanager.dns = "none";
    };
  };
}
