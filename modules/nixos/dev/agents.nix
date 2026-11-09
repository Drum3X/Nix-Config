{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.my.desktop.enable {
    # Prebuilt binaries agents fetch (npm and uvx tools, MCP servers,
    # Playwright browsers) look for /lib64/ld-linux-x86-64.so.2; nix-ld
    # provides it.
    programs.nix-ld.enable = true;
  };
}
