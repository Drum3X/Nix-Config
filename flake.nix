{
  description = "Drum3X's NixOS config (KDE Plasma desktop).";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [self.overlays.default];
    };
    myLib = import ./lib {inherit inputs self;};
  in {
    overlays = import ./overlays {inherit inputs;};

    packages.${system} = import ./pkgs {inherit pkgs;};

    formatter.${system} = pkgs.alejandra;

    nixosConfigurations = {
      nitro = myLib.mkHost {
        hostName = "nitro";
        inherit system;
      };
    };
  };
}
