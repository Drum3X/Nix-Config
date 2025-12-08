{...}: {
  services.zapret = {
    enable = false;
    params = [
      "--dpi-desync=fake --dpi-desync-ttl=1 --dpi-desync-autottl=-2"
    ];
  };
}
