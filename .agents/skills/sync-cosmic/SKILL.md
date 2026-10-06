# sync-cosmic

Sync the live COSMIC DE config (`~/.config/cosmic/`) back into the declarative Nix files:
`modules/home/desktop/cosmic-config.nix` (settings/apps/panel/dock/shortcuts/etc.) **and**
`modules/home/desktop/cosmic-theme.nix` (appearance/theming, including Desktop > Appearance
in COSMIC Settings). Always check both — a "settings changed" sync isn't complete without
checking theming too.

## Two different mechanisms — read the right live path for each

- **`cosmic-config.nix`**: every tracked key is a direct 1:1 `home.file` entry — the `.text`
  value *is* the live file's content. Compare live vs. nix directly.
- **`cosmic-theme.nix`**: most tracked values are the `let`-bound "User-facing knobs" at the
  top of the file (`gaps`, `activeHint`, `frostedIntensity`, etc.), not raw paths. All of
  them are consumed by `mkBuilder` and written only to the **Builder input** path
  (`.../{Light,Dark}.Builder/v2/<key>`) — compare live values there, not the final
  `.../{Light,Dark}/v2/<key>` file. The final file is *computed* by `cosmic-build-theme`
  at activation, so it's a derived artifact, not a second source of truth to sync from.
  COSMIC Settings' Appearance page writes Builder keys to `v2/` too, so that's where live
  changes show up.

## Workflow

1. Read both `cosmic-config.nix` and `cosmic-theme.nix`. For `cosmic-config.nix`, list every
   `home.file` key under `.config/cosmic/`. For `cosmic-theme.nix`, list the user-facing knobs
   and, for each, resolve which live path it actually maps to per the rule above.
2. For each tracked path, read the corresponding live file at `~/.config/cosmic/<path>`.
3. Compare the live value against the nix value.
4. Report:
   - **Changed**: keys where live ≠ nix — show the diff
   - **Unchanged**: keys that already match
   - **Untracked**: live files/keys that exist under `~/.config/cosmic/` but aren't yet
     represented in either nix file — flag these to the user, do not auto-add. Pay special
     attention to a live key with no nix counterpart sitting next to ones that do (e.g. a new
     `v2` sibling of a tracked `v1` key) — that pattern means COSMIC likely migrated a
     schema out from under an existing knob; flag it explicitly as a possible schema change,
     not just a missing key.
5. For changed keys, update the right nix file to match the live values. Preserve RON syntax,
   indentation, and section/comment style. If a knob is Builder-backed, edit the Builder input
   value — never hand-edit the computed final file.
