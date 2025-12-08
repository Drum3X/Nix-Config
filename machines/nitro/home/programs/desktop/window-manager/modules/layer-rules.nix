{...}: {
  programs.niri.settings.layer-rules = [
    {
      matches = [
        {namespace = "^swww-daemon$";}
      ];
      place-within-backdrop = true;
    }
  ];
}
