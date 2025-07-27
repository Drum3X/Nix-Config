{ pkgs, ... }:
{
  boot = {
    consoleLogLevel = 3;

    kernelPackages = pkgs.linuxPackages;
    kernelModules = [ "kvm-intel" ];
    kernelParams = [
      "quiet"
      "nvidia.NVreg_DynamicPowerManagement=0x01" # 0x00: off, 0x01: performance, 0x02: efficiency
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1"
    ];

    initrd = {
      verbose = false;
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
    };

    supportedFilesystems = [ "ntfs" ];

    plymouth.enable = true;
  };
}
