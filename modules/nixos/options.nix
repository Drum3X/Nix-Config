{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  # Everything host-specific is set through these, in hosts/<name>/default.nix.
  # Home Manager modules read them back through `osConfig.hyalo`.
  options.hyalo = {
    user = mkOption {
      type = types.str;
      description = "The single desktop user of this machine.";
    };

    flakePath = mkOption {
      type = types.str;
      default = "/home/${config.hyalo.user}/Config";
      description = "Where this repository is checked out on the machine.";
    };

    desktop = {
      enable = mkEnableOption "the Hyalo desktop (ShojiWM, hyalo-shell, greeter)";

      liveConfig = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Link the ShojiWM config and hyalo-shell to the checkout in
          `hyalo.flakePath` instead of the Nix store, so edits apply on hot
          reload without a rebuild.
        '';
      };
    };

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
      zapret.enable = mkEnableOption "zapret DPI bypass";
    };
  };
}
