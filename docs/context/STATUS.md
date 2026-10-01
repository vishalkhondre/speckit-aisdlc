# Status

Overwrite this file at the end of every session.

**Last updated:** 2026-10-01 · **By:** Claude chat · **Phase:** Discovery and design (no code yet)

## Where we are

- Upstream Spec Kit and Extended Flow (v0.18.0) have been analysed and their layering mechanisms
  verified by installing them; findings are in `docs/research/`. An internal enterprise Spec Kit layer
  was also analysed; that analysis is private and is not kept in this repo.
- Accepted decisions D-001 to D-008: goal, EF-style packaging, no offline install, durable specs,
  interactive commands, extension id `aisdlc`, aisdlc is generic with org-specific content kept in
  separate presets, and the internal layer's material may be adapted if fully de-branded.
- The repo has only these context docs.

## Next actions

1. **Pin upstream 1.0's public contract:** manifest schemas, composition strategies
   (prepend/append/replace), hook events, workflow step types and engine run-state, and what
   changed or was deprecated between 0.7 and 1.0. Write it to `docs/research/upstream-spec-kit.md`.
2. **Capability map:** list candidate capabilities from Extended Flow and the internal layer → keep /
   adapt / drop, plus the target mechanism (extension command, preset prepend/append, workflow step,
   hook), the extension point an organisation preset would use, and the de-branded name for anything
   adapted. Save as `docs/research/capability-map.md`.
3. **Add `LICENSE` and `NOTICE`** (licence choice is open question 1).

## Open questions

1. **Licence for aisdlc.** MIT would match Spec Kit and Extended Flow.
2. **Unattended workflow runs vs interactive commands (D-005).** A prepend preamble applies to every
   invocation. Options: a conditional preamble that only applies inside a workflow run, gates in the
   workflow instead of in commands, or no unattended mode.
3. **Issue tracker support for issue → branch → PR:** GitHub issues only, or a pluggable tracker
   interface (GitHub, Jira via MCP) that organisation presets configure.
4. **Branch naming:** a configurable pattern (prefix, tracker key, slug) rather than one fixed
   convention. In a fresh upstream 1.0.13 project the `git` extension (and its `before_specify` hook)
   was not installed by default.
5. **Session state scope:** per-feature (e.g. `specs/<feature>/.session/`) so parallel feature
   branches don't collide.
6. **Single constitution location:** `.specify/memory/constitution.md` only.
7. **Lifecycle commands beyond upstream:** upstream now ships `converge`, `bug` and `assess`. Which of
   verify, review, secure, deploy, retrospective, guard, router, ship, brownfield scout and remediate
   does aisdlc add on top?
