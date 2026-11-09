{...}: {
  imports = [
    ./options.nix

    ./core/boot.nix
    ./core/fonts.nix
    ./core/locale.nix
    ./core/networking.nix
    ./core/nix.nix
    ./core/nixpkgs.nix
    ./core/packages.nix

    ./hardware/audio.nix
    ./hardware/bluetooth.nix
    ./hardware/nvidia.nix
    ./hardware/power.nix

    ./desktop/plasma.nix
    ./desktop/security.nix
    ./desktop/services.nix

    ./dev/agents.nix

    ./network/dnscrypt.nix
    ./network/f-dpi.nix
    ./network/zapret.nix
  ];
}
