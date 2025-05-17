{ pkgs, ... }:
{
  users.users = {
    drum3x = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "adbusers"
      ];
      shell = pkgs.nushell;
    };
  };
}
