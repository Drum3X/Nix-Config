{ ... }: {
  services.zapret = {
    enable = true;
    params = [
      "--hostspell=hoSt"
      "--dpi-desync=fake --dpi-desync-ttl=3"
    ];
  };
}
