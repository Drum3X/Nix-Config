{ ... }:
{
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            rightcontrol = "layer(altgr)";
          };
        };
      };
    };
  };
}
