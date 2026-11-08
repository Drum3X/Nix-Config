{
  config,
  inputs,
  lib,
  ...
}: {
  # F-Dpi's own module: the app and its setuid core (security.wrappers).
  imports = [inputs.f-dpi.nixosModules.default];

  config = lib.mkIf config.my.network.f-dpi.enable {
    programs.f-dpi.enable = true;

    # F-Dpi's automatic DNS sets DNS-over-TLS on the default link through
    # systemd-resolved, and skips it without resolved: the router's (ISP's)
    # DNS then answers blocked sites with the block page, whatever nfqws does.
    # NetworkManager hands its DNS to resolved once this is on.
    services.resolved.enable = true;

    assertions = [
      {
        assertion = !config.my.network.dnscrypt.enable;
        message = "F-Dpi sets the system DNS through resolved; turn dnscrypt off.";
      }
    ];
  };
}
