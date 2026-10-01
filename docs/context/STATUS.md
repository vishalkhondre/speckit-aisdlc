# Status

Overwrite this file at the end of every session.

**Last updated:** 2026-10-01 · **By:** Claude chat · **Phase:** Discovery and design (no code yet)

## Where we are

- Upstream Spec Kit and Extended Flow (v0.18.0) have been analysed and their layering mechanisms
  verified by installing them; findings are in `docs/research/`. An internal enterprise Spec Kit layer
  was also analysed; that analysis is private and is not kept in this repo.
- Accepted decisions D-001 to D-016 (see `docs/wiki/Decisions.md` for a one-line summary of each).
- Added this session: MIT `LICENSE` and `NOTICE`; four specialist agents in `.claude/agents/`
  (prior-art researcher, software architect, agile delivery consultant, documentation writer);
  `docs/reviews/`; starter wiki pages in `docs/wiki/`; `.github/workflows/wiki-sync.yml`.

## Setup the user must do (once)

1. **Initialise the wiki:** open the repo's Wiki tab and save any first page (GitHub only creates the
   wiki's git repository after that).
2. **Create `WIKI_TOKEN`:** a classic personal access token with `public_repo` scope (or `repo` if the
   repo becomes private), saved as repository secret `WIKI_TOKEN` (Settings → Secrets and variables →
   Actions). Then run the "Publish wiki" workflow once, or push a change under `docs/wiki/`.

## Next actions

1. **Pin upstream 1.0's public contract:** manifest schemas, composition strategies
   (prepend/append/replace), hook events, workflow step types and engine run-state, whether the engine
   can apply behaviour per run (D-010), and what changed or was deprecated between 0.7 and 1.0. Write
   it to `docs/research/upstream-spec-kit.md`. Have `software-architect` review it.
2. **Prior-art sweep:** run `prior-art-researcher` across the candidate capabilities (verify, review,
   secure, deploy, retrospective, guard, router, ship, brownfield onboarding, remediate, docs
   reconciliation, quick flow) before drafting the capability map.
3. **Capability map:** each candidate → keep / adapt / drop, target mechanism, organisation-preset
   extension point, and de-branded name. Save as `docs/research/capability-map.md`; review with
   `software-architect` and `agile-delivery-consultant`; the user decides.

## Open questions

1. **Per-run unattended behaviour (D-010):** can the workflow engine apply a preamble or flag only
   inside workflow runs? Answered by next action 1.
2. **Workflow names:** `aisdlc-feature`, `aisdlc-bugfix`, `aisdlc-quick`, `aisdlc-onboard` are
   placeholders.
3. **Release flow (candidate):** security scan → deployment spec → retrospective. Decide in the
   capability map.
