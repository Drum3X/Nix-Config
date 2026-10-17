{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # From `nixos-generate-config --no-filesystems --show-hardware-config`.
  # Filesystems live in ./disko.nix.
  boot = {
    initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "usbhid" "usb_storage" "sd_mod"];
    kernelModules = ["kvm-intel"];
  };

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    enableRedistributableFirmware = true;
  };

  # Acer Nitro: Intel iGPU drives the panel, the NVIDIA dGPU is offloaded to.
  # Bus ids come from `lspci | grep -E "VGA|3D"` and are set in ./default.nix.
}
