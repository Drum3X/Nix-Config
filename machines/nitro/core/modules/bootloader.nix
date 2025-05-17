{ ... }:
{
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };

    systemd-boot.enable = true;
    timeout = 0;
  };
}
