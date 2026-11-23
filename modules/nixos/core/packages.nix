{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    gh
    git
    pciutils
    usbutils
    wget
  ];
}
