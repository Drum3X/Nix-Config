{...}: {
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      useOSProber = true;
      efiSupport = true;
    };
    
    efi.canTouchEfiVariables = true;
  };
}
