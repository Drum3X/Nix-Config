{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra
    btop
    llm-agents.claude-code
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
      shellAliases.rebuild = "sudo nixos-rebuild switch --flake ~/Config#nitro";
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
