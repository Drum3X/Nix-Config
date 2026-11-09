{pkgs, ...}: {
  # Desktop agent apps, from llm-agents.nix.
  home.packages = with pkgs.llm-agents; [
    antigravity-hub # Google's app for running agents across projects
    claude-desktop
  ];
}
