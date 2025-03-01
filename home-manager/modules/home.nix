{ ... }:
{
  home = {
    username = "drum3x";
    homeDirectory = "/home/drum3x";
    enableNixpkgsReleaseCheck = false;
    sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "zen";
      TERMINAL = "kitty";
      FILE_MANAGER = "nautius";
    };
  };
}
