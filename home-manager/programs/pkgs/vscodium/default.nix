{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nixd
    nixfmt-rfc-style
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    extensions =
      with pkgs.vscode-extensions;
      [
        jnoortheen.nix-ide
        arrterian.nix-env-selector
        ms-python.python
        ms-vscode.cpptools
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          publisher = "dlasagno";
          name = "wal-theme";
          version = "1.1.2";
          sha256 = "sha256-vO9FjzA3+5VTgnBY12eawPCfDzKap07Tgf5jqz/IgN0=";
        }
      ];

    userSettings = {
      "update.mode" = "none";
      "extensions.autoUpdate" = false;
      "window.titleBarStyle" = "custom";

      "workbench.colorTheme" = "Wal";
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
