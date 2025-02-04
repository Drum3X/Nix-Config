{ ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
      ];
    };

    shellAliases = {
      ll = "ls -l";
      resystem = "sudo nixos-rebuild switch --flake .#nitro";
      rehome = "home-manager switch --flake .#drum3x@nitro";
    };
  };
}
