{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nixd
    nixfmt-rfc-style
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      arrterian.nix-env-selector
      ms-python.python
      ms-vscode.cpptools
    ];

    userSettings = {
      "update.mode" = "none";
      "extensions.autoUpdate" = false;
      "window.titleBarStyle" = "custom";

      "editor.fontFamily" = "JetBrainsMono Nerd Font";
      "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font";
      "editor.fontSize" = 18;

      "editor.formatOnSave" = true;
      "editor.formatOnType" = true;
      "editor.formatOnPaste" = true;

      "editor.mouseWheelZoom" = true;

      "nix.serverPath" = "nixd";
      "nix.enableLanguageServer" = true;
    };
  };
}
