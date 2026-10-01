# Status

Overwrite this file at the end of every session.

**Last updated:** 2026-10-01 · **By:** Claude Code · **Phase:** 2 (capability map — prior-art sweep done)

**Work items:** [Project #2](https://github.com/users/vishalkhondre/projects/2) — the board is the list of
what's in flight; this file is the narrative handoff (D-017).

## Where we are

- **#6 merged:** Spec Kit's public contract is pinned at v1.0.13 in `docs/research/upstream-spec-kit.md`.
- **#7 done (PR open, `feature/7-prior-art-sweep`):** all 14 candidate capabilities swept by
  `prior-art-researcher`; combined report, spot-checked against sources and by test installs on 1.0.13:
  `docs/reviews/2026-10-01-prior-art-sweep-prior-art-researcher.md`.
  - **Recommendations (not decisions):** no ADOPT. **DEPEND** for verify (core `converge` plus a thin
    aisdlc layer; `verify-tasks` optional) and optionally `threatspec` for secure. **BORROW** for the
    other twelve. Main sources: Extended Flow (ship, quick flow, docs reconciliation), BMAD-METHOD
    (review triage, retrospective, routing), `intent` (decision log format), SpecKit Companion
    (per-feature state).
  - **Contenders that still need a deep-dive:** SpecKit Companion's schema stability; whether
    spec-gates' git and CI layer works without its agent-specific layer.
- Accepted decisions D-001 to D-024 (summaries in `docs/wiki/Decisions.md`).

## Next actions

1. **#9 — Draft the capability map** from the sweep and the contract implications;
   `software-architect` and `agile-delivery-consultant` review it.
2. **#10 — Decide the capability map** (user), including whether deploy and a release flow are in scope.
3. **#4 — Board setup** (user): confirm *Item closed → Done* and *Pull request merged → Done* are on,
   then close #4.

## Open questions (for the user)

- **#5 — Workflow names** (`needs-decision`): best settled after the capability map.
- **Release flow / deploy in scope?** Decided in #10. The sweep suggests deploy stays thin (a readiness
  and record step plus an organisation hook) or is dropped; upstream leaves deployment to plain CI.
- **Extended Flow has no LICENSE file** (MIT is declared only in its README and manifests). Before
  adapting EF material: ask the author to add one, or record the manifest author as copyright holder
  in `NOTICE`?
- **Alias rule:** the 1.0.13 source accepts un-namespaced extension aliases, contrary to the docs that
  D-006's impact line relies on. Add a note to D-006 / `upstream-spec-kit.md`?
- **Naming:** upstream already uses `handoffs:` in command frontmatter to mean "suggested next
  command"; aisdlc needs a different term for session handoffs.
- **D-024 range confirmation:** `>=1.0.5,<2.0.0` is provisional; confirm in Phase 3.
