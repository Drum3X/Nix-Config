{
  inputs,
  pkgs,
  ...
}:
{
  imports = [ inputs.nix-index-database.homeModules.nix-index ];

  home.packages = with pkgs; [
    nixfmt
    btop
    llm-agents.claude-code
    llm-agents.opencode
    fastfetch
    fd
    nil
    ripgrep
    unzip
    wl-clipboard # wl-copy/wl-paste: CLI tools (gh, claude) copy through it on Wayland

    # What coding agents reach for: JSON, npx, uv/uvx, task runners, and a
    # multiplexer for long-running or parallel sessions.
    jq
    just
    nodejs
    tmux
    uv
  ];

  programs = {
    bash = {
      enable = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    nix-index.enable = true;
    nix-index-database.comma.enable = true;
  };
}
