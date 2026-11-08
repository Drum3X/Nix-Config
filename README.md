# Nix-Config

Drum3X'in NixOS config'i: **COSMIC** masaüstü ve **cosmic-greeter**, Home Manager
NixOS modülü olarak, tek bir `nixos-rebuild switch` ile uygulanır.

- Koyu / açık tema COSMIC Ayarlar'dan değiştirilir. Qt uygulamaları Kvantum ile
  KvLibadwaita (açık) kullanır (`modules/home/theme/qt.nix`).
- Eski ShojiWM + Quickshell (Hyalo) masaüstü artık
  [Drum3X/Hyalo-Shell](https://github.com/Drum3X/Hyalo-Shell) reposunda.

## Yapı

```
flake.nix               inputs, nixosConfigurations.nitro
lib/                    mkHost: nixosSystem + disko + home-manager
hosts/nitro/            donanım, disko (btrfs), my.* seçenekleri
modules/nixos/          sistem modülleri (core, hardware, desktop, network)
modules/home/           Home Manager modülleri (desktop, theme, apps, terminal)
users/drum3x/           kullanıcı hesabı + home.nix
pkgs/                   bu repoda tanımlı paketler (şimdilik boş)
```

Host'a özel her şey `hosts/nitro/default.nix` içindeki `my.*` seçenekleriyle
ayarlanır (`modules/nixos/options.nix`).

## Kurulum

NixOS kurulum ISO'sundan:

```bash
sudo -i
nix-shell -p git
git clone https://github.com/drum3x/nix-config /tmp/nix-config
cd /tmp/nix-config
```

Donanımı karşılaştır (initrd modülleri `hosts/nitro/hardware.nix` ile aynı mı):

```bash
nixos-generate-config --no-filesystems --show-hardware-config
```

**Diski formatla. Bu komut `/dev/nvme0n1` diskini tamamen siler.** Windows ayrı
diskte olmalı:

```bash
nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode destroy,format,mount hosts/nitro/disko.nix
```

Kur ve şifreyi belirle:

```bash
nixos-install --flake .#nitro
nixos-enter --root /mnt -c 'passwd drum3x'
```

Açılıştan sonra repo'yu kalıcı yerine taşı (`my.flakePath`):

```bash
git clone https://github.com/drum3x/nix-config ~/Config
sudo nixos-rebuild switch --flake ~/Config#nitro
```

## Notlar

- NVIDIA hibrit: masaüstü Intel iGPU'da çalışır. Bir programı dGPU'da açmak için
  `nvidia-offload <komut>`.
- Panel, dock, kısayollar ve duvar kağıdı COSMIC Ayarlar'dan yönetilir
  (`~/.config/cosmic`); bu repo onları sabitlemez.
