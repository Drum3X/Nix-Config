# Nix-Config

**English** | [Türkçe](README.tr.md)

Drum3X's NixOS config: a **KDE Plasma 6** desktop with **SDDM**, and Home
Manager as a NixOS module, applied with a single `nixos-rebuild switch`.

- Theme, fonts, icons and apps (Konsole, Dolphin, Kate, Ark, Gwenview, Okular,
  Spectacle, Elisa) are Plasma's defaults.
- Shortcuts, virtual desktops, keyboard layouts and the wallpaper slideshow are
  set from the config through
  [plasma-manager](https://github.com/nix-community/plasma-manager).
  Everything else is changed in System Settings.
- Coding agents (Claude Code, Claude Desktop, Antigravity Hub) come from
  [llm-agents.nix](https://github.com/numtide/llm-agents.nix). Claude Code runs
  its commands in a sandbox (`modules/nixos/dev/agents.nix`).
- [F-Dpi](https://github.com/Drum3X/F-DPI), a sing-box proxy and zapret DPI
  bypass, comes from its own flake.
- The old ShojiWM + Quickshell (Hyalo) desktop now lives in
  [Drum3X/Hyalo-Shell](https://github.com/Drum3X/Hyalo-Shell).

## Layout

```
flake.nix               inputs, nixosConfigurations.nitro
lib/                    mkHost: nixosSystem + disko + home-manager
hosts/nitro/            hardware, disko (btrfs), my.* options
modules/nixos/          system modules (core, hardware, desktop, network, dev)
modules/home/           Home Manager modules (desktop, theme, apps, terminal)
overlays/               pkgs.stable, pkgs.llm-agents, package tweaks
users/drum3x/           user account + home.nix
pkgs/                   packages defined in this repo (empty for now)
```

Everything host-specific is set through the `my.*` options in
`hosts/nitro/default.nix` (`modules/nixos/options.nix`).

## Install

From the NixOS installer ISO:

```bash
sudo -i
nix-shell -p git
git clone https://github.com/drum3x/nix-config /tmp/nix-config
cd /tmp/nix-config
```

Compare the hardware (are the initrd modules the same as in
`hosts/nitro/hardware.nix`?):

```bash
nixos-generate-config --no-filesystems --show-hardware-config
```

**Format the disk. This wipes `/dev/nvme0n1` completely.** Windows must be on
another disk:

```bash
nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode destroy,format,mount hosts/nitro/disko.nix
```

Install and set the password:

```bash
nixos-install --flake .#nitro
nixos-enter --root /mnt -c 'passwd drum3x'
```

After the first boot, move the repo to its permanent place (`my.flakePath`):

```bash
git clone https://github.com/drum3x/nix-config ~/Config
sudo nixos-rebuild switch --flake ~/Config#nitro
```

From then on, `rebuild` does the same.

## Notes

- NVIDIA hybrid: the desktop runs on the Intel iGPU. To run a program on the
  dGPU, use `nvidia-offload <command>`.
- The wallpapers are not in the repo (about 60 MB). The slideshow reads
  `~/Pictures/Wallpapers`, which has to be copied over by hand on a new machine.
