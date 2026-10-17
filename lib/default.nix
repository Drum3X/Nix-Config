{
  inputs,
  self,
}: {
  # One NixOS system per host. Home Manager runs as a NixOS module, so a single
  # `nixos-rebuild switch --flake .#<host>` applies the system and the user.
  mkHost = {
    hostName,
    system,
  }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs self;};
      modules = [
        {
          networking.hostName = hostName;
          nixpkgs.hostPlatform = system;
        }

        inputs.disko.nixosModules.disko
        inputs.home-manager.nixosModules.home-manager
        inputs.shojiwm.nixosModules.default

        ../modules/nixos
        ../hosts/${hostName}
        ../users/drum3x/nixos.nix
      ];
    };
}
