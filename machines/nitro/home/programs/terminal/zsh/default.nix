{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    plugins = [
      {
        name = pkgs.zsh-autocomplete.pname;
        src = pkgs.zsh-autocomplete.src;
      }
      {
        name = pkgs.zsh-autosuggestions.pname;
        src = pkgs.zsh-autosuggestions.src;
      }
      {
        name = pkgs.zsh-syntax-highlighting.pname;
        src = pkgs.zsh-syntax-highlighting.src;
      }
    ];
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
