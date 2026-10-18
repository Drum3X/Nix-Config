{pkgs, ...}: {
  programs.obs-studio = {
    enable = true;
    # nixpkgs adds the driver runpath to OBS's libraries but not to
    # obs-nvenc-test, the helper OBS runs to probe NVENC (the real binary sits
    # behind a wrapper as .obs-nvenc-test-wrapped); without it the probe
    # cannot load libnvidia-encode and NVENC is disabled ("nvenc_lib").
    package = pkgs.obs-studio.overrideAttrs (old: {
      postFixup =
        (old.postFixup or "")
        + ''
          addDriverRunpath $out/bin/.obs-nvenc-test-wrapped
        '';
    });
  };

  home.packages = with pkgs; [
    mpv
    pavucontrol
  ];
}
