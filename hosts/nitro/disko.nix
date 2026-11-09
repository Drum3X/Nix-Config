{...}: {
  # The whole NVMe belongs to NixOS. Windows is on a different disk; GRUB finds
  # it through os-prober.
  disko.devices.disk.main = {
    # By id, not /dev/nvme0n1: the two NVMe drives swap names between boots,
    # and the other one holds Windows.
    device = "/dev/disk/by-id/nvme-BG6_KIOXIA_512GB_ZE3CTETUZ2G1";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          type = "EF00";
          size = "1G";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = ["umask=0077"];
          };
        };

        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = ["-f" "-L" "nixos"];
            subvolumes = let
              options = ["compress=zstd" "noatime"];
            in {
              "@" = {
                mountpoint = "/";
                mountOptions = options;
              };
              "@home" = {
                mountpoint = "/home";
                mountOptions = options;
              };
              "@nix" = {
                mountpoint = "/nix";
                mountOptions = options;
              };
              "@log" = {
                mountpoint = "/var/log";
                mountOptions = options;
              };
              "@swap" = {
                mountpoint = "/swap";
                swap.swapfile.size = "8G";
              };
            };
          };
        };
      };
    };
  };
}
