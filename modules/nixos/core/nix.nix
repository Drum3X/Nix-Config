{
  config,
  inputs,
  lib,
  ...
}:
let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
in
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
      nix-path = config.nix.nixPath;
      # Prebuilt llm-agents packages.
      extra-substituters = [ "https://cache.numtide.com" ];
      extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
    };

    channel.enable = false;

    # `nix run nixpkgs#foo` and `<nixpkgs>` resolve to this flake's pins.
    registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
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
