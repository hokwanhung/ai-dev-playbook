# Agent trust pyramid

Lauren Tan (“Potato”) on how Grokbot, at SpaceX SI, keeps quality up while the volume of agent-written changes goes up. Talk: [All Code Is Slop (Except Mine)](https://ai.engineer/code/2026/talks/lauren-tan) (AI Engineer CODE, 11 Nov 2026). The wording she used is in [sources/lauren-tan-aie-code-2026-transcript.md](sources/lauren-tan-aie-code-2026-transcript.md). This page is the map. Names here follow the opening of that transcript: **Grokbot** and **SpaceX SI**.

The job of the engineer in this account is to maintain or improve the quality of the code while productivity rises. She calls the subject trust: invest in the agent’s environment so the agent does the right thing. A “software factory” is a later result of that investment. It took her six months to ship thousands of pull requests, many of them while she was away; she says the same path can be shorter for someone starting now. The counts later in this page are Grokbot’s reported results.

## Pyramid

She spends time on the agent’s environment as an inverse pyramid. The first two layers are deterministic, and they are used together so the agent is pushed toward the right change by default.

1. **Codebase.** API design, architecture, and refactoring. This layer removes the bad choice, or makes the good path the one that already exists in the tree.
2. **Executable checks.** Lint, type systems, compilers, and tests. A failed check is reproducible. Another line in a rules file or in `AGENTS.md` is easier to skip.

**Verification** sits on those layers. Runtime and formal checks find bugs, check the invariants that must hold, and show whether the agent understood the goal.

**Prose** is the last layer: rules, skills, and `AGENTS.md`. It is for judgment that the lower layers cannot encode.

## Garden

Agents generate output from their inputs, and the codebase is one of the largest inputs. A correction that lives only in a rule is weaker than the same correction made as a check in the repo, because the check runs every time and the code is what the next agent copies.

She treats the codebase as a garden. In 2024 she reviewed about three pull requests from colleagues. The number she cites now is on the order of 300. Each engineer is a team of hundreds or thousands of agents, and code arrives as a stream. Constraints and guardrails are the foundations that new code grows around. The work starts to look like gardening.

Workarounds, anti-patterns, deprecated code, and tech debt spread, because the next agent treats them as the established pattern. Weeds copy themselves. The codebase stays pristine so that what gets copied is the good path.

## Three examples

Dune is the client framework Grokbot built to hold this kind of architecture. She describes it as Next.js for Electron apps. The interesting part is the constraints and lint rules that encode lessons from desktop apps.

**Nuance.** An API that needs a lot of nuance to use well is where slop shows up. React `useEffect` is her example: it has real uses, and agents use it badly. Grokbot bans it in product code and allows it only inside some Dune APIs. That class of mistake no longer shows up in review. This is a Grokbot rule for their product code.

**Directories.** In Cursor, an Electron app, agents imported main-thread code into the renderer and caused long tasks and jank. Grokbot makes the split conventional: two top-level directories, `Electron renderer` and `Electron main`. A dependency-graph analyzer and lint rules forbid imports between them. One less thing to catch by eye.

**Prose as an excuse.** Agents use markdown — docs, comments, rules, and skills — to write down why they did not do the hard thing. They also over-rotate: one small correction becomes a hard rule that can never be broken.

On Cursor, agents reached for imperative timers (`setTimeout`, `requestAnimationFrame`, `requestIdleCallback`) to paper over a clash between VS Code’s imperative style and React’s declarative style. That architecture made the client and the agent slower. Timers created and destroyed in volume drive major garbage collection, lag, and jank. Comments, which she showed in red on a slide, explained why each quick fix was justified. The timers then spread.

Grokbot bans about 99% of comments. Comments go stale, people do not read them, they give the agent an escape hatch, and they are not enforceable. A well-meant note to the next agent does not fail the build. Lint rules with a helpful error tell the agent to fix the root cause.

## Correction rule

Every time they correct an agent, the correction becomes a deterministic check, or they remove that class of problem in the code through API design or architecture.

A lint rule stops new copies of the anti-pattern. The old copies get cleaned up as well. After enough of these, code review has less to look for. At the far end of that process, agents merge most of their own pull requests.

## Verification

Verification is how they raise autonomy and how they check the work. Code review shrinks to artifacts: videos, screenshots, diagrams, and formal-verification results.

Runtime verification means the agent runs the code and uses the debugging tools a person would use, such as the Chrome DevTools protocol. Their runtime-verification skills include a **feature map**: a sitemap of the product’s features from the user’s point of view. “The thing in the left sidebar” then has a shared name. Custom CLIs inside those skills let the agent reuse the same CLI and driver, which spends fewer tokens, and the driver can be tested.

## Order of operations

When you correct an agent, change the codebase first. Add a lint rule so the anti-pattern cannot recur, and remove the old occurrences. Make the verification story strong. That work is a prerequisite for automation.

An inner loop that produces slop, once automated, produces more slop, and the token spend climbs. After the codebase, static analysis, and runtime plus formal verification are in place, an outer loop can sit on those foundations.

## Optional: formal checks, tokens, and the outer loop

Formal verification is a layer they are still experimenting with. It has found bugs. It is one more tool in the environment.

- **TLA+** model-checks major user flows, such as notifications across devices and platforms.
- **Lean** proves selected algorithms. Their custom virtualization library is checked for flicker and jitter.
- **Bombadil** is the library they use for property-based UI tests. It has already caught UI bugs.
- **statechart**, a skill in her plugin pstack (potato stack), draws state machines from the user’s point of view, so a reviewer can look at that diagram next to the video and the screenshots. Formal checks also show whether the agent understood how the product is supposed to work.

She cites a note from Cindy. Six months earlier, subtle bugs were merging and the missing piece was verification. Six months later, about 70% of Cindy’s daily tokens went to verification. Lauren says most of her own token usage goes there too. The techniques are ordinary software engineering. They used to be expensive to understand, write, and maintain. Agents cut that cost, so testing and verification can cover more of the product than used to be economical.

What Grokbot reported in return for the investment:

- She shipped about 3,000 pull requests to production in a month.
- The team shipped about 11,000 pull requests in the following month she describes.
- They cut a new stable client about once a day. The core team ships more, and drive-by contributors ship without full context. In October, about 227 people landed at least one pull request.
- The share of pull requests that are reverted is lower on a relative basis and steady at about half a percent.
- Startup, typing, opening a new chat, and switching chats are faster than at launch. Grokbot is still Electron, so there is a ceiling. She still calls it faster than many other agent UIs at that velocity and contributor count.

The outer loop they run once those foundations hold: Grokbot connectors and routines start Cursor cloud agents and projects, on the order of hundreds or thousands of agents. On each release, Grokbot opens a Cursor project that fuzzes the build by running the app the way a user would, opens a fix pull request for each bug, and auto-merges it. Pull requests tend to be good by default, and most product code no longer needs deep human review.

## What this repo does with it

Two artifacts carry the talk into a session:

| Artifact | Path | Why this shape |
|---|---|---|
| Always-on rule | [`.cursor/rules/trust-pyramid.mdc`](../.cursor/rules/trust-pyramid.mdc) | Short precedence. Loaded even when the model does not open the skill. Outranks Matt Pocock skills on where a correction lives. |
| Skill | [`.cursor/skills/trust-pyramid/SKILL.md`](../.cursor/skills/trust-pyramid/SKILL.md) | The steps: weed, layer, scoped cleanup, evidence. Not listed in `scripts/core-skills.txt`. |

The default on application code is that order, plus `diagnosing-bugs` when something is broken. `grill-with-docs`, `to-spec`, `to-tickets`, `tdd`, and `code-review` stay available when a domain, a spec, or a large-branch review is actually the task. They do not decide where the correction lives. Stack-agnostic constraints for persistence, cache, permissions, queries, collections, and releases stay in [architecture-free-principles.md](architecture-free-principles.md).

Comment policy lives in [`.cursor/rules/agent-operating-invariants.mdc`](../.cursor/rules/agent-operating-invariants.mdc): no comment for a constraint an API or a check can encode; keep a comment that states a host constraint the compiler cannot see; delete a comment only when it justifies the workaround being removed.

### Where it fits

**ASD-BSIH** is the application this was judged against: a NexTore module plus a Vite/React app, with no frontend tests and a backend the agent must not build or restart. The useful part is refusing to copy a weed (the wrong SQL door, a wipe-and-recreate child write) and landing the next repeated mistake in the API, the SQL shape, or a rule the repo already has. A required test, a feature map, a ticket tracker, or an auto-merge loop would fight that repo. Copy the skill and both rule files there only when asked.

**HA_nextore_test** is an install pack: runbooks, compose notes, image tars, a Hyper-V checklist. There is no application tree to constrain, and the runbooks are the product. Do not copy the skill or the rule into that repo.

This page does not install pstack. Grokbot's `useEffect` ban, directory split, and formal-verification tools stay their local choices.
