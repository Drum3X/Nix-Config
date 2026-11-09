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
    };
}
