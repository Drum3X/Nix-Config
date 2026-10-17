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
    };
}
