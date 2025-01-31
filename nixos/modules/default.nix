{ ... }: {
  imports = [
    ./system.nix
    ./users.nix
    ./networking.nix
    ./boot.nix
  ];
}