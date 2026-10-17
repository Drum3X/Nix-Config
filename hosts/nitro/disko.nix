{...}: {
  # The whole NVMe belongs to NixOS. Windows is on a different disk; GRUB finds
  # it through os-prober.
  disko.devices.disk.main = {
    device = "/dev/nvme0n1";
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
