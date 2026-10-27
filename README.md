# AI Dev Playbook

A practical playbook of **important skills and workflows for coding with AI** (Cursor-first).

This repo starts with a thin curated mirror of [mattpocock/skills](https://github.com/mattpocock/skills): always sync from a **pinned upstream SHA**, install only the core few below. It is not a fork that rewrites Matt’s process. More playbook material can grow around this core over time.

## Skills

| Skill | Role |
|---|---|
| `setup-matt-pocock-skills` | One-time per-repo config (tracker, triage labels, doc layout) |
| `grill-with-docs` | Alignment interview that updates glossary / qualifying ADRs |
| `grilling` | Interview primitive (dependency of `grill-with-docs`) |
| `domain-modeling` | Glossary / ADR writing (dependency of `grill-with-docs`) |
| `tdd` | Red-green at seams |
| `to-spec` | Conversation → spec |
| `to-tickets` | Spec → tracer-bullet tickets |
| `diagnosing-bugs` | Hard-bug diagnosis loop |
| `code-review` | Standards + spec review |

The full Matt skill set lives upstream; this repo vendors the subset above under `.cursor/skills/`.

## How to use

1. Refresh the pack from the current pin:

```bash
./scripts/sync-core-skills.sh
```

2. Open the **target app repo** in Cursor (not necessarily this playbook repo).
3. Run `/setup-matt-pocock-skills` once per consuming repo.
4. Daily loop:

```text
/grill-with-docs → /to-spec → /to-tickets → implement with /tdd → /code-review
```

## Sync

Pin file [`scripts/upstream-sha.txt`](scripts/upstream-sha.txt) is the source of truth for which `mattpocock/skills` commit we mirror. Do **not** edit core skill files under `.cursor/skills/` by hand — CI will fail.

`scripts/sync-core-skills.sh` clones or updates `vendor/mattpocock-skills` (gitignored) at that pin, reads `scripts/core-skills.txt`, and copies those skill folders into `.cursor/skills/`. Stale core installs removed from the list are cleaned up; unrelated `.cursor/` content (for example `rules/`) is never deleted.

```bash
# Re-install core skills at the current pin
./scripts/sync-core-skills.sh

# Same as CI drift gate: sync, then fail if the tree changed
./scripts/check-core-skills.sh
```

### Upgrading the pin

Upstream upgrades are deliberate:

1. Merge the weekly (or manually dispatched) **skills-bump** PR when you want to accept newer upstream, or
2. Edit `scripts/upstream-sha.txt` to the desired full SHA, run `./scripts/sync-core-skills.sh`, and commit the pin together with `.cursor/skills/`.

Workflows:

- [`.github/workflows/skills-drift.yml`](.github/workflows/skills-drift.yml) — on every PR/push to `main`, re-sync at the pin and fail on drift
- [`.github/workflows/skills-bump.yml`](.github/workflows/skills-bump.yml) — weekly / `workflow_dispatch`: if upstream `main` is ahead of the pin, open or update a bump PR

## Upstream

- Repository: https://github.com/mattpocock/skills
- Catalog: https://www.skills.sh/mattpocock/skills
- Pin: [`scripts/upstream-sha.txt`](scripts/upstream-sha.txt)

## Authorship

See [docs/authorship.md](docs/authorship.md) for authorship policy locations that skill sync must not overwrite.
