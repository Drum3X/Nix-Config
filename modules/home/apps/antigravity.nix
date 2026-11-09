{pkgs, ...}: {
  # Google's desktop app for running agents across projects.
  home.packages = [pkgs.llm-agents.antigravity-hub];
}
