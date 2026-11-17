{
  config,
  inputs,
  ...
}: {
  # Kioku (github.com/Drum3X/kioku): Claude Code's second brain. Puts the kioku
  # command on PATH and wires the vault into Claude Code on every switch.
  imports = [inputs.kioku.homeManagerModules.default];

  programs.kioku = {
    enable = true;
    vault = "${config.home.homeDirectory}/Documents/Brain";
    # The local checkout while Kioku is in development: edits apply without a
    # rebuild. Remove for a release; the version pinned in flake.lock is used then.
    source = "${config.home.homeDirectory}/Projects/kioku";
  };
}
