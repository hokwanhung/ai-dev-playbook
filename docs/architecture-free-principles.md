# Architecture-free principles

Lessons from the first large app built here with heavy AI use, rewritten so they do not depend on that app's language, folders, or host.

Two artifacts, on purpose:

| Artifact | Path | Why this shape |
|---|---|---|
| Always-on rule | [`.cursor/rules/agent-operating-invariants.mdc`](../.cursor/rules/agent-operating-invariants.mdc) | Short limits that must apply even when the model does not load a skill: no surprise build or deploy, a green build is not a running system, keep comments, git in the owning repo, write repeated lessons down |
| Skill | [`.cursor/skills/architecture-free-principles/`](../.cursor/skills/architecture-free-principles/SKILL.md) | The twelve principles. Loaded when a change can touch persistence, cache, permissions, queries, collections, workflow, or a release |

The full text the agent reads is [references/principles.md](../.cursor/skills/architecture-free-principles/references/principles.md). It lives inside the skill so copying the skill folder into another repo is enough. This page is the human map. When a principle changes, edit the reference and keep this page's summary in step.

Stack-specific mechanics (a host's table names, a UI kit, a folder map) stay in the app that taught them. Add a stack rule only after that stack has already failed once.

## Install into a target repo

1. Copy `.cursor/skills/architecture-free-principles/` into the target repo's `.cursor/skills/`.
2. Copy `.cursor/rules/agent-operating-invariants.mdc` into the target repo's `.cursor/rules/`.
3. Do not add `architecture-free-principles` to `scripts/core-skills.txt`. Sync only manages the upstream pack and would treat a custom name as drift.

## The twelve principles

1. **Write the constraint where the next session will read it.** A plan is one decision. A rule is what stays true. When they disagree, follow the rule.
2. **Start environment-changing work only when someone names it.** Build, restart, deploy, schema, production data, and client-facing wording wait for an explicit ask in the current message.
3. **Match the remedy to the failure.** A cache, an index, a timeout, and an admin account fix different shapes. Change the matching call sites. Leave healthy siblings. Name the non-goals.
4. **A successful build is not a running system.** Stored fields, process restart, and which server is answering are part of the change. Confirm the environment before editing application logic.
5. **One payload, one interpreter.** A flag does not rewrite SQL, JSON, or names. Switching translators means rewriting identifiers in that same edit. Keep both translators when both are already in production. A later wrap (paging, counts) can make an inner name illegal.
6. **Replacing a collection without stable ids deletes it.** Read that parent's children, update diffs, insert new rows, delete orphans. Skip unchanged attachments. Leave small collections alone.
7. **Check three permissions separately.** May they call the operation, may they affect this record, and does the account that persists the change hold the store right. Deny outside callers unless the operation is explicitly marked.
8. **Correctable input and a broken system are different outcomes.** Field errors use the form's field names. Unexpected failures fail once, at the edge. Normalize foreign payloads once.
9. **Return what the next step needs on the answer you already have.** Display names and navigation keys travel with the record unless the person is choosing from a list. A blank workflow state on old rows is a real state.
10. **Cache only while that key still means those bytes.** Immutable ids can live a long time. Ids whose bytes are overwritten in place cannot. Do not raise the global cache to speed up forms. Create the cache object once.
11. **Extend the system that actually runs the request.** A second stack will not see the host's auth or transaction. One transaction covers writes that must succeed or fail together.
12. **A named change is not the whole change.** Classify same-area leftovers, call out schema and data, and keep client text separate from the engineer note. Do not let formatting become the task.
