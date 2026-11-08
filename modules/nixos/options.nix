{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  # Everything host-specific is set through these, in hosts/<name>/default.nix.
  # Home Manager modules read them back through `osConfig.my`.
  options.my = {
    user = mkOption {
      type = types.str;
      description = "The single desktop user of this machine.";
    };

    flakePath = mkOption {
      type = types.str;
      default = "/home/${config.my.user}/Config";
      description = "Where this repository is checked out on the machine.";
    };

    desktop.enable = mkEnableOption "the KDE Plasma desktop and SDDM";

    hardware.nvidia = {
      enable = mkEnableOption "NVIDIA PRIME offload (Intel iGPU + NVIDIA dGPU)";

      intelBusId = mkOption {
        type = types.str;
        example = "PCI:0:2:0";
      };

      nvidiaBusId = mkOption {
        type = types.str;
        example = "PCI:1:0:0";
      };
    };

    network = {
      dnscrypt.enable = mkEnableOption "dnscrypt-proxy as the local resolver";
      f-dpi.enable = mkEnableOption "F-Dpi, the sing-box proxy and zapret DPI bypass app";
      zapret.enable = mkEnableOption "zapret DPI bypass";
    };
  };
}
