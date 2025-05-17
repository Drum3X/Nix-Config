{ config, ... }:
{
  programs.nushell = {
    enable = true;

    shellAliases = {
      ll = "ls -l";
      la = "ls -la";
      resystem = "sudo nixos-rebuild switch --flake .#nitro";
      rehome = "home-manager switch --flake .#drum3x@nitro";
    };

    environmentVariables = config.home.sessionVariables;

    extraConfig =
      let
        config = builtins.toJSON {
          show_banner = false;
        };
      in
      ''
        $env.config = ${config};
      '';
  };
}
