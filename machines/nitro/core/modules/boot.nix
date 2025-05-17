{ pkgs, ... }:
{
  boot = {
    consoleLogLevel = 3;

    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];
    kernelParams = [
      "quiet"
      "mem_sleep_default=deep"
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

    plymouth.enable = true;
  };
}
