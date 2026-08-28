# declare-vicinae-extension

Take a vicinae launcher extension that was installed through the in-app store (a plain,
per-machine directory under `~/.local/share/vicinae/extensions/`, invisible to Nix) and turn
it into a declarative entry in `programs.vicinae.extensions` inside
`modules/home/desktop/launcher/vicinae.nix`, so it's installed identically on every host that
imports that file (currently all 3 NixOS hosts, via `sharedHomeModules` in `flake.nix`).

## Background

- Vicinae discovers "installed extensions" purely by scanning
  `~/.local/share/vicinae/extensions/<dir>/` at startup — there is no manifest/registry file
  anywhere else, and nothing in `settings.json` tracks them.
- The home-manager module (built into home-manager itself, `modules/programs/vicinae/`) exposes
  `programs.vicinae.extensions`, a list of derivations. Each gets written via `xdg.dataFile` to
  `~/.local/share/vicinae/extensions/<name>` where `<name>` is the arg passed to
  `mkExtension`/`mkRayCastExtension` — **not necessarily the same as the directory name the
  store used when it installed the extension.** Always check both names.
- `config.lib.vicinae.mkExtension { name, src, npmDepsHash ? null }` builds via
  `pkgs.buildNpmPackage`. If `npmDepsHash` is omitted, it falls back to `pkgs.importNpmLock`,
  which derives deps straight from the extension's own `package-lock.json` — no manual FOD
  hash prefetch needed in the common case. Only fall back to prefetching a real
  `npmDepsHash` (build once with a placeholder hash, read the mismatch error for the real one)
  if `importNpmLock` fails for that extension (e.g. lockfile version it doesn't understand).
- `config.lib.vicinae.mkRayCastExtension { name, rev, sha256, npmDepsHash ? null }` is for
  extensions that live in the `raycast/extensions` monorepo instead — sparse-checks out
  `extensions/<name>` from there. Use this instead of `mkExtension` if the extension turns out
  to be a Raycast port rather than a vicinae-native one.

## Workflow

1. **Identify the extension.** If the user names one, use that. Otherwise list
   `~/.local/share/vicinae/extensions/` and diff against what's already declared in
   `vicinae.nix`'s `programs.vicinae.extensions` — anything present on disk but not declared is
   a candidate. Read its `package.json` (`name`, `title`, `description`, `author`) — this is
   what you'll use to find and confirm the source.

2. **Find the source repo.** Check in this order, confirming by comparing `title`/`description`/
   `author` against `package.json` in the candidate path (extension names collide across
   authors — a name match alone is not enough):
   - `knoopx/vicinae-extensions` (community monorepo, path `extensions/<name>`) — this is where
     most third-party vicinae-native extensions from the in-app store come from.
   - `vicinaehq/extensions` (official store repo, same layout).
   - If neither has it, search GitHub directly by the extension's exact title/description text,
     and check if `package.json` itself has a `repository`/`source` field.
   - If it turns out to be a Raycast port (check if the same extension exists under
     `raycast/extensions/extensions/<name>`), use `mkRayCastExtension` instead of `mkExtension`
     in the steps below.

3. **Pin a commit.** Get the source repo's default-branch HEAD sha:
   `gh api repos/<owner>/<repo>/commits/HEAD --jq '{sha, date: .commit.committer.date}'`.

4. **Get the fetch hash.** Never hand-type or guess one.
   `nix flake prefetch --json "github:<owner>/<repo>/<rev>"` and take `.hash` — this matches
   what `pkgs.fetchFromGitHub` will produce for the same rev (same tarball, same unpack).

5. **Add the entry** to `programs.vicinae.extensions` in `vicinae.nix`:
   ```nix
   (config.lib.vicinae.mkExtension {
     name = "<name>";
     src = "${pkgs.fetchFromGitHub {
       owner = "<owner>";
       repo = "<repo>";
       rev = "<rev>";
       hash = "<hash-from-step-4>";
     }}/extensions/<name>";
   })
   ```
   Leave `npmDepsHash` out unless step 6 shows `importNpmLock` doesn't work for this extension.

6. **Build and verify it standalone before touching system config.** Don't just check it
   evaluates — build the one derivation and compare its output `package.json` against the
   originally-installed one's `package.json` to confirm it's really the same extension (same
   title/description/commands), not just "it built without error":
   ```
   nix build --impure --expr '
     let flake = builtins.getFlake (toString ./.); in
     builtins.elemAt flake.nixosConfigurations.<host>.config.home-manager.users.ac.programs.vicinae.extensions <index>
   ' --no-link --print-out-paths
   ```

7. **Dry-run the full host** (`nix build .#nixosConfigurations.<host>.config.system.build.toplevel --dry-run`) to confirm nothing else broke.

8. **Remove the stale GUI-installed copy.** `rm -rf ~/.local/share/vicinae/extensions/<on-disk-dir-name>` — use the *actual* directory name from step 1, which may differ from the extension's `name` field (the declarative version lands at `.../extensions/<name>`, which could be a different path). Leaving both around means vicinae sees two entries for the same extension.

9. **Stage the change** (`git add modules/home/desktop/launcher/vicinae.nix`) — don't commit unless asked. Tell the user which extension, its pinned rev, and that `nisw`/`niup` is needed to apply it.
