# Status

Overwrite this file at the end of every session.

**Last updated:** 2026-10-01 · **By:** Claude chat · **Phase:** Discovery and design (no code yet)

**Work items:** [Project #2](https://github.com/users/vishalkhondre/projects/2) — the board is the list of
what's in flight; this file is the narrative handoff (D-017).

## Where we are

- Upstream Spec Kit and Extended Flow (v0.18.0) have been analysed and their layering mechanisms
  verified by installing them; findings are in `docs/research/`. An internal enterprise Spec Kit layer
  was also analysed; that analysis is private and is not kept in this repo.
- Accepted decisions D-001 to D-017 (one-line summaries in `docs/wiki/Decisions.md`).
- In place: handshake docs, MIT licence, four specialist agents (`.claude/agents/`), the wiki published
  from `docs/wiki/` (first publish succeeded), and `scripts/board/bootstrap.sh` for work tracking.

## Next actions

1. **Bootstrap the board (Claude Code):** `gh auth refresh -s project` if needed, then
   `bash scripts/board/bootstrap.sh`. It creates labels, milestones for phases 0–7, and six issues for
   phases 0–2, and adds them to the project. Re-running it is safe.
2. **Board setup (user):** issue *Set up the project board views and built-in workflows*.
3. **Pin the Spec Kit 1.0 public contract** (issue of the same name, Phase 1).
4. **Prior-art sweep**, then **draft the capability map** (Phase 2 issues).

## Open questions

- Workflow names — tracked as issue *Name the aisdlc workflows* (`needs-decision`).
- Release flow in scope? — decided with the capability map.
- Per-run unattended behaviour (D-010) — answered by the upstream contract research.
