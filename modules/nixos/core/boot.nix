{ pkgs, ... }: {
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

    # Tuned for swap in RAM (zram), not on disk: swapping out idle memory is
    # cheaper than dropping file cache, and reading ahead from zram only
    # decompresses pages nobody asked for. Values from Pop!_OS.
    kernel.sysctl = {
      "vm.swappiness" = 180;
      "vm.page-cluster" = 0;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
    };
  };

  zramSwap.enable = true;
}
