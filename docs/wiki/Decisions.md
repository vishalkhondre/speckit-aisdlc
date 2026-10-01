# Decisions

What has been agreed so far, in plain language. The full log, with reasoning and rejected
alternatives, is in [`docs/context/DECISIONS.md`](https://github.com/vishalkhondre/speckit-aisdlc/blob/main/docs/context/DECISIONS.md).

| ID | Decision |
|---|---|
| D-001 | Build an SDLC add-on on top of GitHub Spec Kit that absorbs new Spec Kit releases without breaking its own. |
| D-002 | Ship as standard Spec Kit packages (extension, presets, workflows, bundle). No fork, no bundled copy, no wrapper tool. |
| D-003 | Offline installation is not a requirement; aisdlc depends on a normal `specify-cli` install. |
| D-004 | Specs are durable: `specs/<feature>/` is kept and committed, never deleted. |
| D-005 | Commands are interactive by default and may ask questions. |
| D-006 | The extension id and command namespace is `aisdlc` (`speckit.aisdlc.<command>`). |
| D-007 | aisdlc is generic. Organisation-specific content lives in separate presets. |
| D-008 | Material from an internal enterprise layer may be adapted, fully de-branded. |
| D-009 | Licence: MIT. |
| D-010 | Approval gates live in the workflows; commands stay interactive when run by hand. |
| D-011 | Issue tracking is pluggable: GitHub issues built in, others via organisation presets. |
| D-012 | Branch names follow a configurable pattern, default `feature/<key>-<slug>`. |
| D-013 | Session state is stored per feature, so parallel branches don't collide. |
| D-014 | One constitution, at `.specify/memory/constitution.md`. |
| D-015 | Which extra lifecycle commands to add is decided in the capability map. |
| D-016 | Specialist review agents check proposals before decisions; this wiki is published from the repo. |
