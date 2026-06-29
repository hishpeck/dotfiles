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
    theme.nix                 System wide Stylix + Catppuccin theming (flavor, accent, fonts, cursor)
    desktop/
      cosmic-theme.nix        COSMIC DE appearance — Catppuccin Builder config files (light + dark)
    private.nix               Personal apps: telegram, discord, steam, blender, 3D printing tools
    work.nix                  Work apps: slack, notion
```

## Key Design Decisions

- **`modules/nix/` vs `modules/home/`**: Hard split between NixOS system modules and Home Manager modules. Never mix them. If a domain (e.g. `gui`, `work`) needs both, there are two separate files at the same path under each tree.
- **`nixosHosts` list in `flake.nix`**: Single source of truth for NixOS machines. `nixosConfigurations` is derived from it via `builtins.listToAttrs`. Adding a new NixOS host means adding one entry here only. Non-NixOS generic profiles (`x84_64`, `aarch64`) are added to `homeConfigurations` separately.
- **`nix-update`**: The only way to apply changes on NixOS machines — rebuilds the full NixOS system including the Home Manager module. `hms` (`home-manager switch`) is standalone-only and must not be run on NixOS hosts where HM is managed as a NixOS module.

## Hosts Summary

| Host            | Arch    | GPU   | Form factor   | Notes                                          |
| --------------- | ------- | ----- | ------------- | ---------------------------------------------- |
| ac-main-pc      | x86_64  | AMD   | Desktop       | cloudflare-warp, sshfs Pi5 mount, work+private |
| ac-zenbook-2025 | x86_64  | Intel | Laptop        | cloudflare-warp, work only                     |
| ac-zenbook-2022 | x86_64  | AMD   | Laptop        | private only                                   |
| aarch64         | aarch64 | —     | Generic Linux | HM-only, genericLinux target                   |
| x84_64          | x86_64  | —     | Generic Linux | HM-only, genericLinux target                   |

## Theme

- Catppuccin **Latte** (light) throughout — `flavor` and `accent` are set once in `theme.nix` as `catppuccin.flavor` / `catppuccin.accent` and propagate automatically to all programs via `catppuccin/nix` Home Manager module or manual imports
- Current accent: **pink**
- Font: **Lato** (sans), **FiraCode Nerd Font** (mono)
- Cursor: **Bibata-Modern-Ice**
- Wallpaper: `wallpaper.png` at repo root

### Theming architecture

- `modules/home/theme.nix` — single source of truth: sets `catppuccin.flavor`, `catppuccin.accent`, Stylix base16 scheme, fonts, cursor. Imports `cosmic-theme.nix`.
- `catppuccin/nix` HM module propagates flavor+accent to: bat, btop, fzf, kitty, tmux, yazi, lazygit, chromium automatically.
- Programs that need special handling:
  - **nvim** — flavor+accent injected as `_G.catppuccin_flavor` / `_G.catppuccin_accent` Lua globals in `nvim.nix`; read in `config/nvim/lua/hishpeck/plugins/colorscheme.lua`
  - **tmux** — accent used as `@thm_${accent}` token in status bar config in `tmux.nix`
  - **bat** — fully managed by `catppuccin.bat` module; no manual config needed
  - **sddm** — NixOS module reads `config.catppuccin.flavor` directly (system-level catppuccin module)
- `modules/home/desktop/cosmic-theme.nix` — generates COSMIC Builder config files for both Light (Latte) and Dark (Mocha) themes via `home.file`, then runs `cosmic-ext-ctl build-theme` via `home.activation.buildCosmicTheme` (after `writeBoundary`) to regenerate the computed theme from the Builder files. Imported directly in each COSMIC host's `home.nix` (not in `theme.nix`, since `theme.nix` is a shared module loaded on all hosts including non-COSMIC ones). User-facing knobs (gaps, activeHint, isFrosted) are local vars at the top of the file. `CosmicTheme.Mode` (light/dark toggle) is intentionally NOT managed — user controls it via COSMIC Settings at runtime.
- `cosmic-ctl` (flake input `github:cosmic-utils/cosmic-ctl`) provides `cosmic-ctl` binary (package output is `packages.${system}.cosmic-ext-ctl`, but the binary inside is named `cosmic-ctl`). Used exclusively in `cosmic-theme.nix` for `build-theme` activation.
- **catppuccin/nix does not yet have a COSMIC module** — tracked in catppuccin/nix PR #549 (draft, blocked on upstream). When it lands, `cosmic-theme.nix` can be replaced with a single `catppuccin.cosmic.enable = true` line.
- `noctalia.nix` hardcodes Catppuccin Latte hex values for Material 3 color roles — these are overridden at runtime by `colorSchemes.useWallpaperColors = true`, so they're cosmetically moot and left as-is.

## Conventions

- All relative import paths in `hosts/` go `../../modules/nix/...` or `../../modules/home/...`
- Host `default.nix` = NixOS system config only
- Host `home.nix` = Home Manager config only (passed to home-manager via flake)
- `stateVersion = "24.05"` on all hosts
- User is always `ac`
