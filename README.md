# Matt Pocock core skills pack

Thin curated mirror of [mattpocock/skills](https://github.com/mattpocock/skills) for **Cursor**. Always sync from upstream; only install the core few listed below. This is not a fork that rewrites Matt’s process.

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

The full skill set lives upstream; this repo only vendors the subset above under `.cursor/skills/`.

## How to use

1. Refresh the pack from upstream:

```bash
./scripts/sync-core-skills.sh
```

2. Open the **target app repo** in Cursor (not necessarily this pack repo).
3. Run `/setup-matt-pocock-skills` once per consuming repo.
4. Daily loop:

```text
/grill-with-docs → /to-spec → /to-tickets → implement with /tdd → /code-review
```

## Sync

`scripts/sync-core-skills.sh` clones or updates `vendor/mattpocock-skills` (gitignored), reads `scripts/core-skills.txt`, and copies those skill folders into `.cursor/skills/`. Stale core installs removed from the list are cleaned up; unrelated `.cursor/` content (for example `rules/`) is never deleted.

```bash
./scripts/sync-core-skills.sh
```

## Upstream

- Repository: https://github.com/mattpocock/skills
- Catalog: https://www.skills.sh/mattpocock/skills

## Authorship

See [docs/authorship.md](docs/authorship.md) for authorship policy locations that skill sync must not overwrite.
