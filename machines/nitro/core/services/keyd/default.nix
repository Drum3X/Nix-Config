{ ... }:
{
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            leftshift = "leftshift";
            rightshift = "rightshift";
            rightcontrol = "layer(altgr)";
          };
        };
      };
    };
  };
}
