{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.os-prober
  ];
}
