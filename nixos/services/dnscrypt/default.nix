{ ... }: {
  networking = {    
    nameservers = ["127.0.0.1" "::1"];
  };

  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      listen_addresses = ["127.0.0.1:53" "[::1]:53"];
    };
  };
}
