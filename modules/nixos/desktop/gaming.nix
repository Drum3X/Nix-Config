{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Games run on the Intel iGPU unless offloaded: in Steam, set a game's launch
  # options to `nvidia-offload gamemoderun %command%`; in Prism Launcher, tick
  # "Use discrete GPU" and "Enable Feral GameMode".
  config = lib.mkIf config.my.gaming.enable {
    programs.steam = {
      enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

    programs.gamemode.enable = true;

    users.users.${config.my.user} = {
      # gamemoded's CPU governor and GPU changes are allowed for this group.
      extraGroups = [ "gamemode" ];
      packages = [ pkgs.prismlauncher ];
    };
  };
}
