{ pkgs, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];
    kernelParams = [
      "quiet"
      "loglevel=1"
      "nvidia-drm.modeset=1"
      "acpi_rev_override=1"
      "acpi_enforce_resources=lax"
      "no_console_suspend"
    ];

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];

      kernelModules = [ ];
    };

    extraModulePackages = [ ];
    extraModprobeConfig = ''
      options nvidia NVreg_DynamicPowerManagement=0x02 NVreg_PreserveVideoMemoryAllocations=1
    '';

    tmp.cleanOnBoot = true;
  };
}
