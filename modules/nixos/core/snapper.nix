{ config, ... }:
{
  # Hourly snapshots of /home: NixOS generations roll back the system, not
  # deleted files or broken app settings. Same disk, so not a backup.
  services.snapper = {
    persistentTimer = true;
    configs.home = {
      SUBVOLUME = "/home";
      ALLOW_USERS = [ config.my.user ];
      SYNC_ACL = true;
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_HOURLY = 10;
      TIMELINE_LIMIT_DAILY = 7;
      TIMELINE_LIMIT_WEEKLY = 4;
      TIMELINE_LIMIT_MONTHLY = 0;
      TIMELINE_LIMIT_QUARTERLY = 0;
      TIMELINE_LIMIT_YEARLY = 0;
    };
  };

  # Snapper keeps its snapshots in this subvolume and does not create it.
  # The ACL lets the user browse them without sudo.
  systemd.tmpfiles.rules = [
    "v /home/.snapshots 0750 root root -"
    "a+ /home/.snapshots - - - - u:${config.my.user}:rx"
  ];
}
