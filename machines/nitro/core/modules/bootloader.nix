{...}: {
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot"; 
    };
    
    grub = {
      enable = true;
      device = "nodev"; 
      efiSupport = true;
      useOSProber = true; 
      configurationLimit = 10; 
    };
  };
};