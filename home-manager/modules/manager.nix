{ ... }:
{
  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";
}
