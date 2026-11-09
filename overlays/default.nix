{inputs}: {
  default = final: prev:
  # Packages defined in this repository (pkgs/).
    (import ../pkgs {pkgs = final;})
    // {
      # Escape hatch to the stable channel: pkgs.stable.<name>.
      stable = import inputs.nixpkgs-stable {
        inherit (final.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };

      # AI coding agents from llm-agents.nix: pkgs.llm-agents.<name>.
      llm-agents = inputs.llm-agents.packages.${final.stdenv.hostPlatform.system};

      # GRUB's os-prober, quiet on every rebuild: no debug lines, and no
      # dmraid (no fake RAID here), whose "no block devices found" it reads
      # as device names and hands to lsblk.
      os-prober = (prev.os-prober.override {dmraid = final.emptyDirectory;}).overrideAttrs (old: {
        postFixup =
          old.postFixup
          + ''
            for file in $out/bin/*; do
              wrapProgram $file --set OS_PROBER_DISABLE_DEBUG 1
            done
          '';
      });
    };
}
