# Authorship

This repository started as an empty project init. There was no prior root README or authorship tooling to relocate.

If you add authorship policy later, keep it in these locations so skill sync never overwrites it:

| Path | Purpose |
|---|---|
| `.githooks/` | Local git hooks |
| `scripts/git-*.sh` | Authorship / commit helper scripts |
| `.cursor/rules/authorship.mdc` | Cursor authorship rule |

The sync script only refreshes `.cursor/skills/<core-skill>/` directories listed in `scripts/core-skills.txt`. It never deletes `.cursor/rules/` or other unrelated Cursor content.
