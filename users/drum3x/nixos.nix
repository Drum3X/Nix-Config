{
  inputs,
  self,
  ...
}: {
  users.users.drum3x = {
    isNormalUser = true;
    description = "Drum3X";
    extraGroups = ["networkmanager" "video" "wheel"];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    sharedModules = [inputs.plasma-manager.homeModules.plasma-manager];
    extraSpecialArgs = {inherit inputs self;};
    users.drum3x = ./home.nix;
  };
}
