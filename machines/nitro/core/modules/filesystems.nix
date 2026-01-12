{...}: {
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/616635af-c76b-40e7-83b5-71cd605df76b";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/F746-DA84";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
  };
}
