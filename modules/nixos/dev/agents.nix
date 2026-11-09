{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.my.desktop.enable {
    # Prebuilt binaries agents fetch (npm and uvx tools, MCP servers,
    # Playwright browsers) look for /lib64/ld-linux-x86-64.so.2; nix-ld
    # provides it.
    programs.nix-ld.enable = true;

    # Claude Code policy (managed settings: above the user's own, which stay
    # writable for /model and the like). Bash commands run under bubblewrap:
    # writes only to the project, temp and the caches below; network only to
    # domains Claude asks about. A command the sandbox breaks can still be
    # rerun outside it, with a prompt.
    # The policy reaches every Claude Code (Claude Desktop's built-in one
    # too), but only the wrapped CLI brings these on its own PATH.
    environment.systemPackages = [pkgs.bubblewrap pkgs.socat];
    environment.etc."claude-code/managed-settings.json".text = builtins.toJSON {
      sandbox = {
        enabled = true;
        # Never fall back to running unsandboxed without saying so.
        failIfUnavailable = true;
        filesystem.allowWrite = ["~/.cache"];
        # nix build and friends talk to the daemon, which fetches and builds
        # outside the sandbox.
        network.allowUnixSockets = ["/nix/var/nix/daemon-socket/socket"];
      };
    };
  };
}
