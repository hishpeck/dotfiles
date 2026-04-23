# Dotfiles — Agent Context

NixOS + Home Manager dotfiles for user `ac`. Flake-based. Three named hosts, two generic arch profiles.

## Repository Structure

```
hosts/                        Per-machine configurations
  <hostname>/
    default.nix               NixOS system config — imports nix/ modules
    home.nix                  Home Manager config — imports home/ modules
    hardware-configuration.nix
  aarch64/default.nix         Generic HM-only profile (non-NixOS Linux, aarch64)
  x84_64/default.nix          Generic HM-only profile (non-NixOS Linux, x86_64)

modules/
  nix/                        NixOS (system-level) modules — imported in hosts/*/default.nix
    system/
      default.nix             Base system config: nix settings, boot, networking, pipewire, docker, locale
      amd.nix                 AMD GPU drivers + ROCm
      intel.nix               Intel GPU drivers + kernel params
      laptop.nix              Bluetooth, TLP, libinput, fprintd, fwupd
    gui/
      default.nix             System-level GUI: nix-ld, 1password service + polkit
    desktop/
      de/*.nix                Desktop Environments
      dm/*.nix                Display Managers
      wm/*.nix                Window Managers
    work.nix                  System-level work config

  home/                       Home Manager modules — imported in hosts/*/home.nix
    cli/
      default.nix             Base HM config: git, btop, fzf, lazygit, dev tools (PHP, Node, Rust, Go, Python)
      nvim.nix                Neovim
      tmux.nix                tmux
      yazi.nix                yazi file manager
      zsh.nix                 zsh
    gui/
      default.nix             User-level GUI: fonts, chrome, pavucontrol, udiskie, 1password autostart
      kitty.nix               Kitty terminal emulator config
    desktop/
      launcher/*.nix          Launchers
      shell/*.nix             Desktop shells
    theme.nix                 System wide Stylix + Catppuccin theming
    private.nix               Personal apps: telegram, discord, steam, blender, 3D printing tools
    work.nix                  Work apps: slack, notion, zoom
```

## Key Design Decisions

- **`modules/nix/` vs `modules/home/`**: Hard split between NixOS system modules and Home Manager modules. Never mix them. If a domain (e.g. `gui`, `work`) needs both, there are two separate files at the same path under each tree.

## Hosts Summary

| Host            | Arch    | GPU   | Form factor   | Notes                                          |
| --------------- | ------- | ----- | ------------- | ---------------------------------------------- |
| ac-main-pc      | x86_64  | AMD   | Desktop       | cloudflare-warp, sshfs Pi5 mount, work+private |
| ac-zenbook-2025 | x86_64  | Intel | Laptop        | cloudflare-warp, work only                     |
| ac-zenbook-2022 | x86_64  | AMD   | Laptop        | private only                                   |
| aarch64         | aarch64 | —     | Generic Linux | HM-only, genericLinux target                   |
| x84_64          | x86_64  | —     | Generic Linux | HM-only, genericLinux target                   |

## Theme

- Catppuccin **Latte** (light) throughout — set in `theme.nix` and referenced by name in `sddm.nix`, `noctalia.nix`
- Font: **Lato** (sans), **FiraCode Nerd Font** (mono)
- Cursor: **Bibata-Modern-Ice**
- Wallpaper: `wallpaper.png` at repo root

## Conventions

- All relative import paths in `hosts/` go `../../modules/nix/...` or `../../modules/home/...`
- Host `default.nix` = NixOS system config only
- Host `home.nix` = Home Manager config only (passed to home-manager via flake)
- `stateVersion = "24.05"` on all hosts
- User is always `ac`
