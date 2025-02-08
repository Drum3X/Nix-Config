pkgs: {
  screenshot = pkgs.writers.writeNuBin "screenshot" {
    makeWrapperArgs = with pkgs; [
      "--prefix PATH : ${
        lib.makeBinPath [
          slurp
          wayshot
          swappy
        ]
      }"
    ];
  } (builtins.readFile ./screenshot.nu);
}
