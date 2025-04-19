{ ... }:
{
  programs.nushell = {
    enable = true;

    shellAliases = {
      ll = "ls -l";
      resystem = "sudo nixos-rebuild switch --flake .#nitro";
      rehome = "home-manager switch --flake .#drum3x@nitro";
    };

    extraConfig = ''
      $env.config.show_banner = false
    '';
  };
}
