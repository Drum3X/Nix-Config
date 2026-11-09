{pkgs, ...}: {
  # Desktop agent apps, from llm-agents.nix.
  home.packages = with pkgs.llm-agents; [
    antigravity-hub # Google's app for running agents across projects
    # Without the bubblewrap FHS env it ships in: that env sets
    # no-new-privileges, so sudo fails in its terminal and agents. The
    # generic-linux binaries it downloads (claude-code, uv) run through
    # nix-ld instead (modules/nixos/dev/agents.nix).
    claude-desktop.unwrapped
  ];
}
