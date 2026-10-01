# Decisions

Append-only. Never edit an accepted entry — supersede it with a new one that references it.
Status values: `accepted` (user decided), `proposed` (agent recommendation awaiting the user), `superseded`.

---

### D-001 — Project goal
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** Create `vishalkhondre/speckit-aisdlc`, combining the best of Spec-Kit Extended Flow and
an internal enterprise Spec Kit layer on top of GitHub Spec Kit. It must absorb new upstream Spec Kit
releases without breaking its own releases. (Scope refined by D-007.)

---

### D-002 — Packaging follows the Extended Flow model
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** Ship as standard Spec Kit packages installed on a stock `specify-cli`: an extension
(own namespaced commands), presets (compose onto core commands via `prepend`/`append`; new
templates), workflows (orchestration on upstream's workflow engine), and a bundle with its own
catalogs. No vendoring, no wrapper CLI.

**Why:** Composition lets upstream changes to core commands flow through untouched. A vendored
Spec Kit snapshot with full-copy command overrides needs a hand merge on every upstream release,
and upstream moves fast (1.0.13 as of 2026-10-01).

**Alternatives rejected:**
- Vendored Spec Kit + wrapper CLI + replacement overrides — upgrade cost and silent breakage via private APIs.

---

### D-003 — No offline / single-wheel install requirement
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** Offline install is not a requirement at the moment. speckit-aisdlc depends
on upstream `specify-cli` installed normally.

**Why:** Removes the main reason to vendor Spec Kit.

---

### D-004 — Specs are durable
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** `specs/<feature>/` is kept and committed. The finish step keeps all other EF
behavior (gather PR context, clean up other temporary run artifacts and the `.specify/feature.json`
pointer, commit, open PR) but never deletes the spec directory.

**Why:** Durable specs are needed for tracker and wiki linkage, retrospectives, decision logs, and
spec-to-code traceability.

**Alternatives rejected:**
- EF behavior (specs deleted after documentation reconciliation; docs layer is the only durable truth).

---

### D-005 — Commands are interactive
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** Commands run interactively by default (may ask the user questions).

**Why:** Keeps human-in-the-loop behavior such as clarification and branch-naming prompts.

**Impact:** EF's "Workflow Runtime" never-ask preamble must not be prepended globally — it is baked
into every invocation, including manual ones. How workflow runs get unattended behavior is open
(see STATUS.md).

---

### D-006 — Extension id and command namespace: `aisdlc`
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** The extension id is `aisdlc`. Every speckit-aisdlc command is `speckit.aisdlc.<command>`
in manifests, which agents with skills see as `/speckit-aisdlc-<command>`.

**Why:** In Spec Kit 1.0 the extension id is a mandatory command namespace, and aliases must stay
inside it. `aisdlc` is free in the upstream community catalog (checked 2026-10-01) and matches the
pattern `^[a-z0-9-]+$`.

**Alternatives rejected:**
- A company-specific name — not suitable for a general-purpose tool.
- `sdlc` — agent recommendation; user preferred `aisdlc`.

**Impact:** Short un-namespaced aliases (e.g. `speckit.verify`) are not possible in 1.0.

---

### D-007 — aisdlc is generic; organisation-specific content lives elsewhere
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** Build `aisdlc` as a generic, company-neutral Spec Kit add-on. Organisation-specific
content — compliance metadata sections, branch conventions, tracker and wiki defaults — is delivered
as separate presets in separate (private where needed) repos that install on top of aisdlc.

**Why:** Keeps this repo publishable and reusable, and keeps proprietary material out of it.

**Impact:** Clean-room rule (AGENTS.md hard rule 7): ideas may inform the design, but no code,
prompts or templates are copied from proprietary sources. aisdlc must expose extension points
(templates, config, hooks) that an organisation preset can fill.

---

### D-008 — Internal enterprise layer content may be reused, de-branded
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** The user confirmed the internal enterprise layer's material shared in the claude.ai
Project contains no IP concerns, so its prompts, templates and code may be adapted into aisdlc.
Everything adapted must be fully de-branded: no company name, abbreviation or product prefix in
templates, prompts, file or folder names, config keys, environment variables, variable names, or
examples.

**Supersedes:** the clean-room clause of D-007 (the rest of D-007 stands: aisdlc is generic and
organisation-specific defaults live in separate presets).

**Impact:** Adapted material gets neutral names (e.g. an `aisdlc`-scoped state folder and config
keys, `PROJ-123`-style tracker examples). The private analysis of that layer stays out of this repo.

---

### D-009 — MIT licence
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** aisdlc is released under the MIT licence.

**Why:** Matches Spec Kit and Extended Flow, keeps reuse and attribution simple (`NOTICE`).

---

### D-010 — Workflows own the approval gates; commands stay interactive
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** Human approval gates live in the workflows. Commands stay interactive when run by hand
(D-005). An unattended preamble is added only if the workflow engine can apply it per run rather than
to every invocation.

**Open:** whether the engine supports per-run behaviour — part of the upstream contract research.

---

### D-011 — Pluggable issue tracker
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** Issue → branch → PR automation goes through a tracker interface. GitHub issues are built
in; other trackers (e.g. Jira via MCP) are supplied by organisation presets.

---

### D-012 — Configurable branch naming
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** Branch names follow a configurable pattern (prefix, tracker key, slug), defaulting to
`feature/<key>-<slug>`.

---

### D-013 — Per-feature session state
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** Session state (gates, decision log, handoffs) is stored per feature under
`specs/<feature>/`, so parallel feature branches never collide.

---

### D-014 — Single constitution
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** One constitution, at upstream's location `.specify/memory/constitution.md`. Anything that
generates or proposes constitution content (e.g. brownfield onboarding) writes there, with human review.

---

### D-015 — Lifecycle commands decided in the capability map
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** Which lifecycle commands aisdlc adds beyond upstream (verify, review, secure, deploy,
retrospective, guard, router, ship, brownfield scout, remediate, …) is decided in
`docs/research/capability-map.md`, after prior-art review.

---

### D-016 — Specialist review agents and a published wiki
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** The repo carries four Claude Code subagents in `.claude/agents/`:
- `prior-art-researcher`, `software-architect`, `agile-delivery-consultant` — read-only reviewers
  (no write tools). Before a significant decision, the relevant reviewers assess the proposal and
  their reports are saved to `docs/reviews/`. They advise; the user decides.
- `documentation-writer` — maintains human-facing pages in `docs/wiki/` only.

`docs/wiki/` is published one way to the GitHub wiki by `.github/workflows/wiki-sync.yml` on every
push to `main`. The wiki is never edited directly.

**Why:** The spec-driven tooling space is crowded; independent, evidence-based review reduces rework.
One-way publishing keeps the repo the single source of truth.

**Alternatives rejected:**
- Agents writing directly to the wiki — drifts from the repo, two sources of truth.

**Limits:** All agents run on the same model and share its blind spots; key decisions still benefit
from human expert review. The SAFe-fluent consultant keeps aisdlc framework-neutral; SAFe-specific
behaviour belongs in organisation presets.
