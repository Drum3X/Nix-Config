{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    git
    os-prober
    pciutils
    usbutils
    wget
  ];
}
