{inputs, ...}: {
  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
    };

    backupFileExtension = "hm-backup";
  };
}
