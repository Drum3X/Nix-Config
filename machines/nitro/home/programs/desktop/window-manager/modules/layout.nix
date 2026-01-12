{...}: {
  programs.niri.settings.layout = {
    gaps = 12;
    background-color = "#00000000";

    focus-ring = {
      enable = true;
      width = 4;
      active = {
        color = "#f8bbdc";
      };
    };

    border.enable = false;
  };
}
