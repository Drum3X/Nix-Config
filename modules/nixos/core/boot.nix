{pkgs, ...}: {
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    loader = {
      efi.canTouchEfiVariables = true;

      # GRUB rather than systemd-boot: Windows lives on another disk, and
      # os-prober is what puts it in the menu.
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        configurationLimit = 10;
      };
    };

    tmp.cleanOnBoot = true;
  };

  zramSwap.enable = true;
}
