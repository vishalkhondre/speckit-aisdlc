# speckit-aisdlc — Agent Context

Always-on context for any AI agent (Claude Code, Claude chat, Copilot, Cursor) working in this repo.
Keep this file short. Depth lives in the files it points to.

## Goal

Build **aisdlc**, a generic, company-neutral SDLC add-on for **GitHub Spec Kit**, combining the best
ideas of **Spec-Kit Extended Flow** (MIT) with lessons from enterprise use. It must absorb every new
upstream Spec Kit release without breaking its own releases. Organisation-specific content (templates,
conventions, tracker defaults) lives in separate presets outside this repo (D-007).

## Hard rules

1. **Never vendor or fork Spec Kit.** speckit-aisdlc installs on top of a stock `specify-cli` (D-002, D-003).
2. **Compose, never replace, core commands.** Change core behavior only via preset `prepend`/`append`
   strategies or hooks. A full replacement copy of a core command or template is a defect unless a
   decision in `docs/context/DECISIONS.md` explicitly allows it.
3. **Depend only on Spec Kit's public contract**: extension/preset/workflow/bundle manifests, hook
   events, workflow step types, and documented CLI commands. No imports of `specify_cli` internals,
   no private functions. Any unavoidable dependency on engine internals must be listed in
   `docs/research/upstream-spec-kit.md` under "Internal dependencies".
4. **Specs are durable** (D-004). Nothing deletes `specs/<feature>/`.
5. **Commands are interactive** (D-005). Do not install a global "never ask questions" preamble.
6. **Upstream compatibility is a release gate.** CI must install the supported Spec Kit versions
   (and the latest release) and exercise the bundle before any release ships.
7. **Generic and de-branded (D-007, D-008).** No organisation-specific names, templates, conventions
   or defaults in this repo. Content adapted from the internal enterprise layer is allowed but must be
   fully de-branded: no company name, abbreviation or product prefix in templates, prompts, file or
   folder names, config keys, environment variables, variable names, or examples (use neutral
   placeholders such as `PROJ-123`). Code or text taken from Extended Flow or Spec Kit (both MIT)
   keeps its copyright notice and is listed in `NOTICE`.

## Session protocol (the Claude Code ↔ Claude chat handshake)

The repo is the single source of truth. Chat history and per-product memory are not.

- **Start of session:** `git pull`, then read `docs/context/STATUS.md` and `docs/context/DECISIONS.md`.
- **One editor at a time.** Only one product (Claude Code or Claude chat) edits the repo at once. If
  that can't be guaranteed, work on a branch and merge through a pull request.
- **Before a significant decision:** run the relevant reviewers in `.claude/agents/` and save their
  reports to `docs/reviews/` (see `docs/reviews/README.md`). In Claude chat, read the agent file and
  apply it as the review instructions.
- **End of session:** rewrite `docs/context/STATUS.md` (overwrite, do not append), append any new
  decisions to `docs/context/DECISIONS.md`, and run `documentation-writer` if decisions, status or
  design changed. Commit everything together.
- **Only the user makes decisions.** Agent recommendations go in STATUS.md as open questions or in
  DECISIONS.md with status `proposed` until the user accepts them.
- Typical split: Claude chat for research, design and trade-offs; Claude Code for implementation,
  tests and CI. Either may do either.

## Specialist agents (`.claude/agents/`, D-016)

| Agent | Role | Writes |
|---|---|---|
| `prior-art-researcher` | Does a capability already exist? Adopt, depend, borrow, or build | Nothing (report returned) |
| `software-architect` | Hard rules, upstream contract, upgrade safety, extension points | Nothing (report returned) |
| `agile-delivery-consultant` | Fit with real team delivery; framework-neutral, SAFe-fluent | Nothing (report returned) |
| `documentation-writer` | Human-facing pages published to the GitHub wiki | `docs/wiki/` only |

## Repo map

| Path | Purpose |
|---|---|
| `AGENTS.md` | This file — always-on context |
| `CLAUDE.md` | Imports this file for Claude Code |
| `LICENSE`, `NOTICE` | MIT licence (D-009); attribution for any third-party material |
| `.claude/agents/` | Specialist subagents (D-016) |
| `.github/workflows/wiki-sync.yml` | Publishes `docs/wiki/` to the GitHub wiki on push to `main` |
| `docs/context/STATUS.md` | Current state, last session, next actions, open questions |
| `docs/context/DECISIONS.md` | Append-only decision log (`D-###`) |
| `docs/research/` | Analyses of upstream Spec Kit and Extended Flow; later the capability map |
| `docs/reviews/` | Specialist agent review reports |
| `docs/wiki/` | Source of the GitHub wiki — never edit the wiki directly |

Source layout (extension, presets, workflows, bundle) will be added here once decided.

## Glossary

- **`aisdlc`** — speckit-aisdlc's extension id and command namespace (D-006): `speckit.aisdlc.<command>`,
  shown to skill-based agents as `/speckit-aisdlc-<command>`.
- **Upstream** — github/spec-kit (`specify-cli`).
- **EF** — markuswondrak/spec-kit-extended-flow.
- **Compose** — preset command override with `strategy: prepend|append`, leaving the upstream body intact.
