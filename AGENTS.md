# Working in this repo

Drum3X's NixOS flake: one host (`nitro`), KDE Plasma 6, Home Manager as a NixOS
module. Decisions and their history live in the owner's Kioku vault (project
`config`); this file holds only how to work here.

## Layout

- `hosts/nitro/`: machine-specific: disko layout, hardware, and the `my.*`
  values for this host.
- `modules/nixos/`, `modules/home/`: system and user modules, imported by
  explicit lists in each `default.nix`. Host differences go through the `my.*`
  options in `modules/nixos/options.nix`, not new conditionals.
- `users/drum3x/`: the user and their Home Manager entry point.
- `overlays/`: package changes; add a `pkgs/` directory when a local package
  is needed.

## Commands

Use the `justfile` recipes; `just` lists them.

- `just eval`: evaluate the system without building. Enough when only adding
  a package: do not build the whole system for that.
- `just build`: full build. Needed for module and service changes; if it will
  be heavy (new large inputs, a kernel or driver change), ask first.
- `just check`: what CI runs (`nix flake check --no-build`, `nix fmt -- --ci`).
  Run it before every commit.
- `just fmt`: format with nixfmt (RFC 166 style). Never alejandra.
- `just diff`: build and show the package diff against the running system.
- `just up [input…]`: update flake inputs. Only when asked.

Activating is the owner's step: suggest `just switch` inside the repo, or
`nh os switch` from anywhere; agents have no sudo here.

## Style

- Comments are few and say why, not what.
- Commit messages: `area: summary` (`nix:`, `cli:`, `snapper:`, `nitro:`…), the
  reason in the body.

## Settled, do not bring back

The Claude Code bubblewrap sandbox, the Helix module, nixos-hardware (only
early KMS was taken from it), fwupd in this config (Plasma already enables it)
and a weekly flake.lock update bot.
