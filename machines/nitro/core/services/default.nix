{ ... }:
{
  imports = [
    ./xserver
    ./pipewire
    ./systemd-suspend
    ./greetd
    ./polkit
    ./keyring
    ./power-profiles
    ./upower
    ./udisks2
    ./devmon
    ./gvfs
    ./keyd
    ./zapret
    ./dnscrypt
    ./openssh
    ./blueman
    ./ananicy
  ];
}
