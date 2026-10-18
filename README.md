# Hyalo

Drum3X'in NixOS masaüstü: **ShojiWM** (floating Wayland compositor) üzerinde
**Quickshell** ile yazılmış, liquid glass temalı bir shell, aynı görünümde kilit
ekranı ve greeter.

- Cam efekti: bar, dock ve paneller sadece yarı saydam bir silüet çizer. Gerçek
  kırılmayı ShojiWM'in `ISLAND_GLASS` shader'ı `hyalo-*` layer namespace'lerine uygular.
- Kilit ekranı ve greeter compositor shader'ına güvenemez (session-lock yüzeyi /
  cage). Camı kendi çizerler (`config/shell/shaders/frost.frag`).
- Tema gün batımında koyuya, gün doğumunda açığa geçer (darkman, İstanbul konumu).

## Yapı

```
flake.nix               inputs, nixosConfigurations.nitro, packages.hyalo-shell
lib/                    mkHost: nixosSystem + disko + home-manager + shojiwm
hosts/nitro/            donanım, disko (btrfs), hyalo.* seçenekleri
modules/nixos/          sistem modülleri (core, hardware, desktop, network)
modules/home/           Home Manager modülleri (desktop, theme, apps, terminal)
users/drum3x/           kullanıcı hesabı + home.nix
config/shojiwm/         ShojiWM TypeScript config'i (src/index.tsx)
config/shell/           hyalo-shell QML (shell.qml = masaüstü, greeter.qml = giriş)
pkgs/hyalo-shell/       shell paketi: shader derleme + hyalo-shell / hyalo-greeter
```

Host'a özel her şey `hosts/nitro/default.nix` içindeki `hyalo.*` seçenekleriyle
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

İlk kurulum ShojiWM'i kaynaktan derler (Rust + V8, binary cache yok). Bu, epey
zaman alır.

Açılıştan sonra repo'yu kalıcı yerine taşı (`hyalo.flakePath`):

```bash
git clone https://github.com/drum3x/nix-config ~/Config
sudo nixos-rebuild switch --flake ~/Config#nitro
```

## Tasarım üzerinde çalışmak (canlı mod)

`hosts/nitro/default.nix` içinde `hyalo.desktop.liveConfig = true;` yap ve bir
kez `nixos-rebuild switch` çalıştır. Bundan sonra:

- `~/.config/shojiwm` doğrudan `~/Config/config/shojiwm` dizinini gösterir.
  Değişiklik yapıp **Super+Shift+R** ile compositor'ı yeniden yükle.
- `~/.config/quickshell/hyalo` doğrudan `~/Config/config/shell` dizinini
  gösterir. Quickshell dosya değişince kendini yeniden yükler. Shader
  değiştirdiysen önce `hyalo-shell-build-shaders ~/Config/config/shell` çalıştır.

Greeter'ı ayrı bir pencerede denemek için (şifre kontrolü yapmaz):

```bash
HYALO_GREETER_DEMO=1 hyalo-greeter
```

## Kısayollar

| Tuş | İş |
| --- | --- |
| Super+Return, Super+T | Ghostty |
| Super+Q | Vivaldi |
| Super+E | Nautilus |
| Super, Super+A, Super+Space | Launcher |
| Super+V | Pano geçmişi |
| Super+N | Kontrol merkezi |
| Super+L | Kilitle |
| Super+D | Pencereyi kapat |
| Super+F / Super+M | Büyüt |
| Super+Shift+F | Tam ekran |
| Super+S | Bu workspace'i tiling yap / geri al |
| Super+Tab | Pencere değiştirici |
| Super+1..9 | Workspace'e git |
| Super+Ctrl+1..9 | Pencereyi workspace'e taşı |
| Super+Ctrl+↑/↓, Super+Ctrl+tekerlek | Önceki / sonraki workspace |
| Super+←/→, Super+Shift+←/→ | Tile odak / taşı |
| Super+sürükle | Pencereyi taşı / boyutlandır |
| Print, Super+Shift+S | Bölge ekran görüntüsü (swappy) |
| Shift+Print | Monitör ekran görüntüsü |
| Super+Shift+P | Ekranları kapat |
| Alt+Shift | TR / US klavye |
| Super+Shift+R / Super+Shift+Q | ShojiWM yeniden yükle / çık |

## Notlar

- NVIDIA hibrit: masaüstü Intel iGPU'da çalışır. Bir programı dGPU'da açmak için
  `nvidia-offload <komut>`.
- Dock'taki sabit uygulamalar `users/drum3x/home.nix` içinde, `hyalo.dock.pinned`
  listesindedir (desktop entry id'leri).
- Duvar kağıdını değiştirmek için `home.nix` içinde `hyalo.wallpaper = ./resim.jpg;`.
- `config/shojiwm/` ShojiWM'in MIT lisanslı varsayılan config'inden türetildi
  (`config/shojiwm/LICENSE`).
