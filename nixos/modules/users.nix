{ pkgs, ... }:
{
  users.users = {
    drum3x = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
    };
  };

}
