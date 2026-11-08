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

    ./desktop/cosmic.nix
    ./desktop/security.nix
    ./desktop/services.nix

    ./network/dnscrypt.nix
    ./network/zapret.nix
  ];
}
