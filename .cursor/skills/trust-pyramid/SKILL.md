---
name: trust-pyramid
description: >
  Land a correction in the API, the structure, or an executable check before
  adding prose. Use when implementing, fixing, or reviewing application code,
  and when an agent repeats a mistake. Existing repo rules win. Does not
  demand tests, tickets, a feature map, or an outer automation loop.
---

# Trust pyramid

Where a repeated mistake is written down matters more than another paragraph of instructions. The codebase is what the next agent copies.

## When to use

- Implementing, fixing, or reviewing application code
- The same agent mistake has shown up again

Skip this skill for typos, copy edits, questions, and doc-only packs (runbooks, image tars, install checklists). Those repos have no application tree to constrain.

## Steps

1. Before copying a local pattern, treat a workaround, a deprecated path, or an anti-pattern as a weed. If the repo already has a rule or skill for it, follow that. Do not add a second prose rule for the same constraint. Do not spread the weed because it is already in the tree.
2. Land the constraint in this order, and say which layer you used:
   - API or structure that removes the wrong choice.
   - An executable check whose message names the root fix.
   - Prose only when the constraint needs judgment, or when it is a host fact the compiler cannot see.
3. In the area already being changed, remove old copies of that pattern and the comments that only justify them. Leave comments that state a host constraint (two SQL doors, IIS, a process the agent must not restart). Do not sweep the rest of the repo.
4. Verify the user-facing behavior when the UI changed. Report what ran and what happened. When the running system needs a build or restart the user has not asked for, say what is unverified and what they would run. A green compile is not that evidence.
5. Do not open an outer loop (auto-merge, unattended fuzzing, a plugin install). Do not demand a test suite, an issue tracker, or a feature map. `diagnosing-bugs` still runs the diagnosis. `grill-with-docs`, `to-spec`, `to-tickets`, `tdd`, and `code-review` are optional, and they do not decide where the correction lives.

Obey `.cursor/rules/agent-operating-invariants.mdc` for build, restart, deploy, schema, production data, and client-facing sends. Obey `.cursor/rules/trust-pyramid.mdc` when this skill and a Matt Pocock skill disagree. `architecture-free-principles` still covers persistence, cache, permissions, queries, collections, and releases.

## Examples that stay local

These are Grokbot's rules, not defaults for every app:

- `useEffect` is banned in their product code and allowed only inside some framework APIs. Do not copy that ban into another React app.
- They split `Electron main` and `Electron renderer` and forbid cross-imports, because agents were importing main-thread code into the renderer.
- Comments that explained timer workarounds (`setTimeout`, `requestAnimationFrame`, `requestIdleCallback`) taught the next agent to repeat them. The fix was a check that names the root cause, plus deleting those excuse comments.

A NexTore module that already forbids mixing NQL and `ZZ_OBJ` names, or forbids the agent to rebuild the host, is the same idea already encoded. Follow that rule. Do not invent a lint rule on top of it.

## Install into another repo

Copy this folder to that repo's `.cursor/skills/trust-pyramid/`, and copy both `.cursor/rules/trust-pyramid.mdc` and `.cursor/rules/agent-operating-invariants.mdc` into that repo's `.cursor/rules/`. Skip doc-only packs. Do not add `trust-pyramid` to `scripts/core-skills.txt`.

In this playbook, the human map is [docs/agent-trust-pyramid.md](../../../docs/agent-trust-pyramid.md). That page does not travel with the skill.
