{...}: {
  services.dnscrypt-proxy = {
    enable = false;
    settings = {
      listen_addresses = ["127.0.0.1:53" "[::1]:53"];
    };
  };
}
