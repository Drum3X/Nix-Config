# Nix-Config

[English](README.md) | **Türkçe**

Drum3X'in NixOS config'i: **KDE Plasma 6** masaüstü ve **SDDM**, Home Manager
NixOS modülü olarak, tek bir `nixos-rebuild switch` ile uygulanır.

- Tema, fontlar, ikonlar ve uygulamalar (Konsole, Dolphin, Kate, Ark, Gwenview,
  Okular, Spectacle, Elisa) Plasma'nın varsayılanlarıdır.
- Kısayollar, sanal masaüstleri, klavye düzenleri ve duvar kağıdı slayt
  gösterisi config'ten,
  [plasma-manager](https://github.com/nix-community/plasma-manager) ile
  ayarlanır. Geri kalan her şey Sistem Ayarları'ndan değiştirilir.
- Kodlama ajanları (Claude Code, Claude Desktop, Antigravity Hub)
  [llm-agents.nix](https://github.com/numtide/llm-agents.nix)'ten gelir. Claude
  Code komutlarını sandbox içinde çalıştırır (`modules/nixos/dev/agents.nix`).
- [F-Dpi](https://github.com/Drum3X/F-DPI) (sing-box proxy ve zapret DPI
  bypass) kendi flake'inden gelir.
- Eski ShojiWM + Quickshell (Hyalo) masaüstü artık
  [Drum3X/Hyalo-Shell](https://github.com/Drum3X/Hyalo-Shell) reposunda.

## Yapı

```
flake.nix               inputs, nixosConfigurations.nitro
lib/                    mkHost: nixosSystem + disko + home-manager
hosts/nitro/            donanım, disko (btrfs), my.* seçenekleri
modules/nixos/          sistem modülleri (core, hardware, desktop, network, dev)
modules/home/           Home Manager modülleri (desktop, theme, apps, terminal)
overlays/               pkgs.stable, pkgs.llm-agents, paket ayarları
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

Sonrasında `rebuild` aynı işi yapar.

## Notlar

- NVIDIA hibrit: masaüstü Intel iGPU'da çalışır. Bir programı dGPU'da açmak için
  `nvidia-offload <komut>`.
- Duvar kağıtları repoda değil (yaklaşık 60 MB). Slayt gösterisi
  `~/Pictures/Wallpapers` klasörünü okur; yeni bir makinede bu klasörü elle
  kopyalaman gerekir.
