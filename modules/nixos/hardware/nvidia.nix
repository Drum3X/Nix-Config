{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.hardware.nvidia;
in
{
  config = lib.mkMerge [
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          intel-media-driver # VA-API
          vpl-gpu-rt # Quick Sync (oneVPL) on Gen12+ / Raptor Lake
        ];
      };
    }

    # The Intel iGPU renders the desktop; `nvidia-offload <cmd>` runs a program
    # on the dGPU, which otherwise stays powered down.
    (lib.mkIf cfg.enable {
      services.xserver.videoDrivers = [
        "modesetting"
        "nvidia"
      ];

      hardware.nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        # Turing (GTX 16 / RTX 20) or newer.
        open = true;
        # Unfree, so not in any binary cache: it compiled on every driver or
        # nixpkgs update, and with PRIME offload on Wayland it shows little.
        nvidiaSettings = false;

        powerManagement = {
          enable = true;
          finegrained = true;
        };

        prime = {
          offload = {
            enable = true;
            enableOffloadCmd = true;
          };
          inherit (cfg) intelBusId nvidiaBusId;
        };
      };
    })
  ];
}
