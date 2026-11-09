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

    # F-Dpi (github.com/Drum3X/F-DPI): sing-box proxy and zapret DPI bypass.
    f-dpi = {
      url = "github:Drum3X/F-DPI";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # AI coding agents, updated daily (github.com/numtide/llm-agents.nix). Not
    # following nixpkgs: its binary cache only matches its own nixpkgs.
    llm-agents.url = "github:numtide/llm-agents.nix";

    # Plasma settings (shortcuts, virtual desktops) from Home Manager.
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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
