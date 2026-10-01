# Status

Overwrite this file at the end of every session.

**Last updated:** 2026-10-01 · **By:** Claude Code · **Phase:** 3 (skeleton and compatibility CI)

**Work items:** [Project #2](https://github.com/users/vishalkhondre/projects/2) — the board is the list of
what's in flight; this file is the narrative handoff (D-017).

## Where we are

- **Design is done.** The capability map (`docs/research/capability-map.md`, revision 2) is accepted (D-029);
  its open questions are answered by D-030 to D-036.
- Accepted decisions D-001 to D-038 (one-line summaries in `docs/wiki/Decisions.md`). New this session:
  **D-037** aisdlc's preset uses priority 50 so organisation presets at the default 10 rank above it;
  **D-038** workflow names `aisdlc-feature`, `aisdlc-bugfix`, `aisdlc-quick`, `aisdlc-onboard` (closes #5).
- Phase 3 issues are on the board (milestone *Phase 3 · Skeleton and compatibility CI*): #16–#21.
- **#16 bundle skeleton (PR #23 open, `feature/16-bundle-skeleton`):** `extension/`, `preset/`,
  `workflows/aisdlc-feature/`, `bundle/` at 0.0.1, plus `scripts/dev/install-local.sh`. Verified on Spec Kit
  1.0.5 and 1.0.13: validate, install, skill registration for two integrations, template resolution, workflow
  run, `bundle build`. `software-architect` review (APPROVE WITH CHANGES):
  `docs/reviews/2026-10-01-bundle-skeleton-software-architect.md`. A1, A4, A5, A7 and A8 are applied; A2,
  A3 and A6 are acceptance criteria on #19/#20 (issue comments).
- **Known limit:** a local bundle supplies only its manifest, so `bundle install <dir>` alone fails. The dev
  path adds each component from its directory first, and the bundle then owns 0 components (`bundle remove`
  leaves them). A release catalog (#20) fixes this.

## Next actions

1. **Build phase 3** in order: #16 bundle skeleton (PR #23) → #17 config loader → #18 setup command → #19
   compatibility CI → #20 release checks → #21 confirm the D-024 range.
2. **#4 — Board setup** (user): confirm *Item closed → Done* and *Pull request merged → Done*, then close #4.

## Open questions (for the user)

- **#21 — D-024 range confirmation** (`needs-decision`): after compatibility CI (#19) runs.
