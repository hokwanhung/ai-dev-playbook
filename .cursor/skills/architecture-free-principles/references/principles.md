# Architecture-free principles

Use these when the next system's language, framework, folder layout, and size are unknown. Add a stack-specific rule only after that stack has already failed once.

Skip a principle when this change cannot violate it.

## 1. Write the constraint where the next session will read it

Chat memory and a finished plan do not bind the next session. After a repeated mistake, record the constraint in the place that session is required to load: a standing rule, a skill that triggers on the workflow, or the checklist for that kind of task.

A plan records one change: what was wrong, what was chosen, what was refused, and what a person must still do. A rule records what is still true after that change. When they disagree, follow the rule and correct the plan the next time you touch it. An earlier fix can teach the wrong name. Leave that sentence in force and every later session repeats it.

Ask only the questions that would change the plan. Update the same plan when the scope or the failure mode changes.

## 2. Start environment-changing work only when someone names it

Build, restart, deploy, schema apply, production data, and client-facing wording can destroy a running session or send the wrong text. Investigating code is allowed. Running those actions is allowed when the person asked for that action in the current message.

Say what changed and why a restart or a migration matters. Continue work that depends on the new runtime only after they confirm the process is up. A skill that rebuilds or replies to a client should refuse to start on its own.

## 3. Match the remedy to the failure

Name the shape of the failure before choosing a tool.

- A short cache helps when the same expensive read repeats. It does not help a payload that is large on purpose, a per-row rescan, or an export of every record.
- An index or a longer timeout does not fix a query that joins an unbounded set.
- Raising privilege on one failed write does not mean every similar write should run as an administrator.

Look at sibling call sites. Change the ones whose shape matches the incident. Leave healthy sites that merely share a risk class. Ship one slice. Write the non-goals down. If a wide change is reverted, the system is back to the previous behavior. Plan again from that fact.

How often a pattern appears is evidence of convention, age, or a shared helper. It is not proof that the pattern is the one to copy. Say so when you did not measure.

## 4. A successful build is not a running system

Typecheck and compile prove the source is consistent. They do not prove the running process has the new stored fields, the new configuration, or the server the client is actually calling.

Treat runtime shape as part of the change. Name the stored field or config that must exist, whether startup sync or a script creates it, and that a rebuild without a process restart often changes nothing. Finish by saying what to verify when the error is an unknown column or a missing field.

Before changing application logic, confirm which environment is answering: local process, remote host, stale proxy, or a deploy script that no longer matches the known-good copy. Missing data is often the wrong target.

## 5. One payload, one interpreter

If two translators can run the same string (two query languages, two JSON casings, two name mappings), a boolean flag does not rewrite the string. Copy a neighboring call that already works, including which translator it uses. If you switch translators, rewrite the identifiers in that same edit.

Keep both translators when both are already in production. A single new API looks simpler and breaks every healthy caller. Do not hide a parser mistake by encoding characters the parser treats as syntax. Switch to the translator that accepts those characters.

Anything that wraps a query afterward (paging, counts, an outer select) can make a name legal in the inner text and illegal in the composed text. Keep aliases in scope for the wrapped form. Expand a star only on the outermost select when the inner query joins tables that share column names.

## 6. Replacing a collection without stable ids deletes it

A replace-the-children operation compares keys. Rows whose keys are absent are inserts. Rows whose keys are missing from the new list are deletes. Sending new rows with empty keys deletes every existing child and creates new ones.

That is expensive when each row is its own stored object with permissions and indexes, and it breaks anything that pointed at the old id: attachments, grants, audit. Read only that parent's children. Update rows that changed. Insert rows that are new. Delete orphans. If the incoming file or attachment id is unchanged, skip the work. If the parent delete already removes children, do not delete them again.

Do not load the entire child table and filter it in memory. Do not point the replace at an unscoped all-rows read. Do not bypass the platform's permission model with a bulk write unless that bypass is an explicit decision. Fix one hot path and time it. Leave small collections alone.

## 7. Three permissions, checked separately

- May this caller invoke the operation?
- May this caller affect this record, in this state?
- Does the account that actually persists the change hold delete, write, or grant on that record?

A role check on the entry point can succeed while the save runs as the logged-in user and the store refuses the delete. Run that write as a principal that holds the store permission. Do not switch every similar write to an admin account because one path failed.

On a network boundary, deny by default. Allow an outside caller only with an explicit mark on that operation.

Pass the acting identity into the work. A background job has no request, and it still needs a chosen principal. Use the same domain operations the request path uses.

## 8. Correctable input and a broken system are different outcomes

If the user can fix the input, return a structured field error on the channel the client already knows how to paint, using the same field names the form uses. If the caller is not allowed, the record is gone, or the system failed, fail at one edge with a trace id.

Do not catch an unexpected failure and return success. Do not make every validation look like a crash.

Normalize foreign payload shapes once, at the boundary. Attach credentials and refresh them in one place, and allow a single refresh in flight. One listener should own navigation to the error screen.

## 9. Return what the next step needs on the answer you already have

If the person is not choosing from a list, the response that identified the record should include the display names and the keys required to open it. A second list call, then taking the first row, is a race and a guess whenever more than one row can match.

Keep list and lookup endpoints for real pickers. A user-driven change may look up a label inside options that are already loaded. Do not delete those endpoints after removing the silent callers.

When behavior depends on status, store the state, describe allowed moves as data, and recompute who may act from the state plus the role columns. A blank state on old rows is a real state. Define the small set of actions it still allows.

## 10. Keep a cached value only while that key still means those bytes

Decide the lifetime from the key, not from how rarely someone edits the screen.

- Entity screens that must show the latest save: do not cache across a remount.
- Catalogs whose contents change while the key stays the same: a short lifetime, aligned with the server cache if there is one.
- Bytes that are immutable for that id (a new upload creates a new id): a long lifetime is safe.
- Bytes that are overwritten in place under the same id: a long lifetime serves the old bytes. Refresh when the list or the save that changed them completes.

Do not raise the global cache to make forms feel faster. Do not copy a long lifetime from an immutable id onto a mutable id. Invalidate after the business result says the write succeeded, and invalidate every other screen that shows the same change. Keep volatile data, such as a live conversation, on a different cache root from stable data, such as configuration. Otherwise a chat update wipes settings.

A cache object rebuilt on every render or every request does not cache. Create it once.

## 11. Extend the system that actually runs the request

The host's threading, routing, and composition are the architecture. A second stack (its own dependency container, its own routing style, async handlers the dispatcher never awaits) will not see the host's auth, transaction, or caller.

Handlers bind the request, check entry permission, map contracts, and call the domain. The domain owns rules, validation, and the transaction. Persistence stays behind that. One transaction covers the writes that must succeed or fail together. Inner steps join it instead of committing their own.

Stored write models, read projections, and API contracts stay different types when the store is reflection-driven or the grid query is not the public contract.

## 12. A named change is not the whole change

A ticket title is a slice. Other commits in the same area can change the same behavior. Classify each candidate as the ticket, related, another area, or schema and data. Ask before including the related ones. Call out schema and data in their own step, and apply them only with an explicit yes. Take older commits first. Resolve a conflict by what each side was trying to do. Stop when the other side was never requested.

Do not let formatting, comment cleanup, or warning cleanup become the task. Existing comments stay. If an edit makes a comment false, correct that comment. Add a comment only for a constraint the code cannot show.

Client text and engineer text are different artifacts. Read the product first so the reply does not promise behavior that already exists. The client version states the effect. The engineer version may name the cause. Group repeated incidents by a small set of known causes, with a confidence note, instead of treating each ticket as a new kind of failure.

In a workspace that contains several repositories, status, diff, and commit run in the repository that owns the files.
