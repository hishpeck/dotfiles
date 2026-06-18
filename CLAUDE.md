IMPORTANT: Read [AGENTS.md](AGENTS.md) at the start of every conversation before doing anything else. It contains critical architectural constraints — violating them (e.g. running `hms` on a NixOS host) will produce incorrect results.

## Skills

Skills live in `.agents/skills/`. Each subdirectory is a skill with a `SKILL.md` containing its instructions.

| Skill | Invocation | Description |
|---|---|---|
| sync-cosmic | `/sync-cosmic` | Sync live COSMIC DE config back into `cosmic-config.nix` |

When the user invokes a skill (e.g. `/sync-cosmic`), read the corresponding `.agents/skills/<name>/SKILL.md` and follow its instructions.
