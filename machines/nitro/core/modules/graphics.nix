{ config, ... }:
{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    graphics.enable = true;

    nvidia = {
      modesetting.enable = true;
      open = true;
      nvidiaSettings = false;
      package = config.boot.kernelPackages.nvidiaPackages.beta;

      powerManagement = {
        enable = true;
        finegrained = true;
      };

      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };

        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };
}
