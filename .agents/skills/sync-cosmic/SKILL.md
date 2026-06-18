# sync-cosmic

Sync the live COSMIC DE config (`~/.config/cosmic/`) back into the declarative Nix file
(`modules/home/desktop/cosmic-config.nix`).

## Workflow

1. Read `modules/home/desktop/cosmic-config.nix` to identify every tracked config path
   (keys under `home.file` whose path starts with `.config/cosmic/`).
2. For each tracked path, read the corresponding live file at `~/.config/cosmic/<path>`.
3. Compare the live value against the `.text` value in the nix file.
4. Report:
   - **Changed**: keys where live ≠ nix — show the diff
   - **Unchanged**: keys that already match
   - **Untracked**: live files that exist under `~/.config/cosmic/` but are not yet in the nix file — flag these to the user, do not auto-add
5. For changed keys only, update `modules/home/desktop/cosmic-config.nix` to match the live
   values. Preserve RON syntax, indentation, and section comment style.
