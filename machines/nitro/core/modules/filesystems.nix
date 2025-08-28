{ ... }:
{
  fileSystems = { 
    "/" = { 
      device = "/dev/disk/by-uuid/2c6a94b5-de78-42fe-9af9-d7a272ef0982";
      fsType = "ext4";
    };

    "/boot" = { 
      device = "/dev/disk/by-uuid/2c6a94b5-de78-42fe-9af9-d7a272ef0982";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };
}
