{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.hyalo.network.zapret.enable {
    services.zapret = {
      enable = true;
      params = [
        "--dpi-desync=fake --dpi-desync-ttl=1 --dpi-desync-autottl=-2"
      ];
    };
  };
}
