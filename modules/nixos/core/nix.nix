{ config, ... }:
{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
      auto-optimise-store = true;
      trusted-users = [
        "root"
        config.my.user
      ];
      # `<nixpkgs>` resolves to this flake's nixpkgs in nix.conf too, not only
      # through NIX_PATH; NixOS pins the registry entry itself.
      nix-path = config.nix.nixPath;
      # Prebuilt llm-agents packages.
      extra-substituters = [ "https://cache.numtide.com" ];
      extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
    };

    channel.enable = false;

    # Local builds (F-Dpi, kioku) get only the CPU and disk time the desktop
    # leaves free, so they do not stutter it; idle, they still run at full speed.
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
  };

  # `nh os switch` shows the package diff before activating. Its cleaner
  # replaces nix.gc (the two conflict) and always keeps the last 5 generations.
  programs.nh = {
    enable = true;
    flake = config.my.flakePath;
    clean = {
      enable = true;
      dates = "daily";
      extraArgs = "--keep 5 --keep-since 7d";
    };
  };
}
