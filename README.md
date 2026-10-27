# AI Dev Playbook

A practical playbook of **important skills and workflows for coding with AI** (Cursor-first).

This repo is two layers:

1. **Core pack** — a thin curated mirror of [mattpocock/skills](https://github.com/mattpocock/skills), synced from a **pinned upstream SHA**. It is not a fork that rewrites Matt’s process.
2. **Playbook layer** — your own reusable skills, rules, docs, and scripts learned from real projects. That layer grows around the core; sync never overwrites it.

Use this repo as the place to **consolidate** what worked in one app repo so the next repo can reuse it.

## Skills (core pack)

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

The full Matt skill set lives upstream; this repo vendors the subset above under `.cursor/skills/`. Names listed in [`scripts/core-skills.txt`](scripts/core-skills.txt) are **managed by sync** — do not edit them by hand.

## How to use (in a target app repo)

1. In this playbook, refresh the core pack from the current pin:

```bash
./scripts/sync-core-skills.sh
```

2. Open the **target app repo** in Cursor (not necessarily this playbook repo).
3. Copy or symlink the skills you need into that repo’s `.cursor/skills/` (core pack and any playbook-owned skills), or open both workspaces if your workflow supports it.
4. Run `/setup-matt-pocock-skills` once per consuming repo.
5. Daily loop:

```text
/grill-with-docs → /to-spec → /to-tickets → implement with /tdd → /code-review
```

## Consolidating experience from other repos

When another project teaches you a durable agent habit (a review checklist, a deploy ritual, a domain interview, a commit policy), bring the **reusable part** here instead of leaving it trapped in that app’s `.cursor/`.

### What belongs here vs what stays in the app

| Keep in the app repo | Bring into this playbook |
|---|---|
| Product domain, secrets, env wiring | Cross-repo workflows and checklists |
| One-off “fix this service” notes | Named skills you would invoke again |
| Generated `docs/agents/` from setup | Generalized rules (authorship, PR shape) |
| App-specific MCP / API keys | Scripts that sync or verify playbook content |

Rule of thumb: if you would paste the same instructions into a second repo next month, it belongs in the playbook.

### Choose the right artifact

| Artifact | Path in this repo | Use when |
|---|---|---|
| **Skill** | `.cursor/skills/<name>/SKILL.md` | On-demand workflow (“when I say X, do Y”) |
| **Rule** | `.cursor/rules/<name>.mdc` | Always-on constraint (authorship, never do Z) |
| **Doc** | `docs/<topic>.md` | Human narrative, ADRs, how the playbook itself works |
| **Script** | `scripts/*.sh` | Deterministic install/check/sync (not prompt text) |

Skills load when relevant; rules always cost context. Prefer a **skill** for procedures and a **rule** for short invariants.

### Do not put playbook-owned skills in the core list

Sync only manages names in [`scripts/core-skills.txt`](scripts/core-skills.txt) (tracked via `.cursor/skills/.core-skills-managed`).

- **Never** add your custom skill to `core-skills.txt` — the next sync would replace or delete it from the managed set incorrectly.
- **Never** hand-edit a core Matt skill to “patch” it for one project. Upstream changes win on pin bump; local forks of core skills drift and fail CI.
- **Do** add a sibling folder: `.cursor/skills/my-workflow/SKILL.md`. Sync leaves unmanaged skill dirs alone.

### Recommended intake loop (from an app → this playbook)

1. **Capture in the app first** — run the workflow until it works; keep notes in a scratch skill or chat export.
2. **Strip app specifics** — remove repo names, private URLs, customer jargon, and secrets. Prefer placeholders (`YOUR_SERVICE`, `docs/agents/…`) or “read the consuming repo’s config” instructions.
3. **Name it for reuse** — folder + frontmatter `name` must match, lowercase with hyphens (`land-pr`, `release-hotfix`). Write a `description` that states *what* and *when* (trigger phrases), so the agent can route to it.
4. **Land it here** under `.cursor/skills/<name>/` (and optional `references/`, `scripts/`). Keep `SKILL.md` short and actionable; put long tables in sibling files the skill tells the agent to open.
5. **Register it for humans** — add a row to the playbook-owned skills table below (or create that table on first custom skill) and a one-line note in `docs/` if the “why” matters.
6. **Try it in a second repo** — if it only makes sense in the original app, it was not ready to consolidate; move the app-specific bits back and leave a thinner skill here.
7. **Promote to a rule only if always-on** — three-line invariants (e.g. authorship) → `.cursor/rules/`; multi-step jobs stay skills.

### Skill shape (minimum)

```text
.cursor/skills/my-workflow/
├── SKILL.md           # required
├── references/        # optional long material
└── scripts/           # optional helpers the agent can run
```

```markdown
---
name: my-workflow
description: >
  What it does and when to use it. Include the phrases a human would say.
---

# My workflow

## When to use
- …

## Steps
1. …
```

### Consolidating rules and docs

- **Rules:** put durable, always-on policy under `.cursor/rules/` (see [docs/authorship.md](docs/authorship.md) for paths sync must not overwrite).
- **Docs:** use `docs/` for playbook meta (how sync works, authorship, design notes). App glossaries and ADRs produced by `/grill-with-docs` stay in the **consuming** repo unless the insight is playbook-wide.
- **Scripts:** add under `scripts/` when the procedure should be mechanical (sync, check, codegen). Prefer bash that CI can run on `ubuntu-latest`.

### Anti-patterns

- Editing vendored core skills “just this once”
- Dumping an entire app `.cursor/` tree into this repo without generalizing
- Turning every preference into a rule (context bloat)
- One mega-skill that mixes deploy, review, and domain modeling — split by job
- Committing secrets, tokens, or customer data “for realism”

## Playbook-owned skills

None yet beyond the core pack. When you consolidate the first custom skill, list it here:

| Skill | Source / lesson | Role |
|---|---|---|
| _(add rows)_ | _(which project taught this)_ | _(one-line job)_ |

## Sync (core pack only)

Pin file [`scripts/upstream-sha.txt`](scripts/upstream-sha.txt) is the source of truth for which `mattpocock/skills` commit we mirror. Do **not** edit core skill files under `.cursor/skills/` by hand — CI will fail.

`scripts/sync-core-skills.sh` clones or updates `vendor/mattpocock-skills` (gitignored) at that pin, reads `scripts/core-skills.txt`, and copies those skill folders into `.cursor/skills/`. Stale core installs removed from the list are cleaned up; unrelated `.cursor/` content (rules, playbook-owned skills) is never deleted.

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
