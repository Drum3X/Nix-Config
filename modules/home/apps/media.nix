{ pkgs, ... }: {
  programs.obs-studio = {
    enable = true;
    # nixpkgs adds the driver runpath to OBS's libraries but not to
    # obs-nvenc-test, the helper OBS runs to probe NVENC; without it the probe
    # cannot load libnvidia-encode and NVENC is disabled ("nvenc_lib"). The
    # helper inherits OBS's environment, so the driver path goes there: a
    # wrapper, where patching the binary rebuilt all of OBS from source.
    package = pkgs.symlinkJoin {
      inherit (pkgs.obs-studio) name meta;
      paths = [ pkgs.obs-studio ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/obs --prefix LD_LIBRARY_PATH : ${pkgs.addDriverRunpath.driverLink}/lib
      '';
    };
  };

  home.packages = [
    # KDE's video player; volume is in Plasma's own audio applet.
    pkgs.haruna
    # YouTube Music client (formerly th-ch/youtube-music).
    pkgs.pear-desktop
  ];
}
