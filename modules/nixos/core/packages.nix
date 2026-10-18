{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gh
    git
    os-prober
    pciutils
    usbutils
    wget
  ];
}
