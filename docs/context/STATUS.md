# Status

Overwrite this file at the end of every session.

**Last updated:** 2026-10-01 · **By:** Claude Code · **Phase:** 1 → 2 (upstream contract pinned; capability map next)

**Work items:** [Project #2](https://github.com/users/vishalkhondre/projects/2) — the board is the list of
what's in flight; this file is the narrative handoff (D-017).

## Where we are

- **#6 done (PR open, `feature/6-upstream-contract`):** Spec Kit's public contract is pinned at v1.0.13 in
  `docs/research/upstream-spec-kit.md`: manifest schemas, composition strategies, hooks and
  `EXECUTE_COMMAND`, workflow engine, bundles, changes 0.7 → 1.0.13, and seeded *Internal dependencies*.
  `software-architect` review (APPROVE WITH CHANGES, all findings applied):
  `docs/reviews/2026-10-01-upstream-contract-software-architect.md`.
- Headline findings: the workflow engine has **no per-run mechanism** (resolved by D-023); hooks are
  agent-interpreted and skip `condition`/ignore `priority`, so they are weak for mandatory behaviour;
  workflow overlays and slots are **project-level only** (no package can ship them); command-step output
  is `exit_code` only.
- Accepted decisions D-001 to D-024 (summaries in `docs/wiki/Decisions.md`). New this session:
  **D-023** unattended runs use workflow gates plus an artifact check after each command step;
  **D-024** supported Spec Kit range `>=1.0.5,<2.0.0` (provisional until Phase 3).

## Next actions

1. **#7 — Prior-art sweep** (Phase 2), then **#9 — Draft the capability map** (uses the contract
   implications), then **#10 — Decide the capability map**.
2. **#4 — Board setup** (user): confirm *Item closed → Done* and *Pull request merged → Done* are on, then
   close #4.

## Open questions (for the user)

- **#5 — Workflow names** (`needs-decision`): best settled after the capability map.
- **Release flow in scope?** Decided in #10.
- **D-024 range confirmation:** `>=1.0.5,<2.0.0` is provisional; confirm or adjust in Phase 3 when the
  compatibility CI exists.
