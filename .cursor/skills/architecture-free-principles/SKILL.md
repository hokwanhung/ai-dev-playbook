---
name: architecture-free-principles
description: >
  Apply stack-agnostic engineering constraints when implementing, reviewing,
  or planning a change and the architecture or size of the system is unknown
  or different from the last project. Use for persistence, cache, permissions,
  queries, collection updates, workflow state, releases, cherry-picks, and
  client-facing wording. Also use when the user asks for reusable rules, a
  playbook, or lessons that should survive a new stack.
---

# Architecture-free principles

## When to use

- A non-trivial change to data access, caching, authorization, validation, child records, workflow, search results, or a release
- Review of a change that might repeat a known failure (wipe-and-recreate, mixed query dialects, cache copied from the wrong kind of id, a ticket that is not the whole diff)
- The user asks to carry lessons into another repo

Skip this skill for typos, copy edits, and questions that cannot touch those concerns.

## Steps

1. Read [references/principles.md](references/principles.md).
2. Apply only the principles this change can violate. Leave the others unused.
3. Name the non-goals in the plan or the reply when a wider rewrite is tempting.
4. Obey `.cursor/rules/agent-operating-invariants.mdc` for build, restart, deploy, schema, production data, and client-facing sends. This skill does not authorize those.
5. Do not add this skill to `scripts/core-skills.txt` or edit vendored core skills. Sync would treat it as part of the upstream pack.

## Install into another repo

Copy this folder to that repo's `.cursor/skills/architecture-free-principles/` and copy `.cursor/rules/agent-operating-invariants.mdc` to that repo's `.cursor/rules/`. The reference file travels with the skill. The playbook `docs/` page does not.
