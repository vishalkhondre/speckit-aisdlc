# Spec-Kit Extended Flow — research notes

Source: markuswondrak/spec-kit-extended-flow, **v0.18.0** (MIT). Analysed 2026-10-01: full source
read, its 63 tests run (pass), installed into a fresh upstream 1.0.13 project.

## How it layers on Spec Kit

No fork, no vendoring, no wrapper CLI. Declares `speckit_version >=0.11.2` (no upper bound).

| Mechanism | What EF ships |
|---|---|
| Extension `extendedflow` | 8 own commands: documentation, documentation-init, finish, project-init, quick-plan, quick-implement, quick-review, doc-check |
| Preset `spec-kit-extended-flow` (priority 10) | 2 new templates (`review-findings`, `documentation`); one 20-line "Workflow Runtime" preamble (never ask, never block, stay in project, always summarise) **prepended** to 15 commands — core, `bug.*`, and its own unattended ones |
| Preset `sub-agent-delegation` (priority 20) | One preamble prepended to 8 parallelizable core commands; maps `.specify/integration.json` → Claude `Task` / Copilot `runSubagent` / opencode `task`, sequential fallback |
| Workflows (3) | Feature, Bugfix, Quick, on upstream's engine (`shell`, `command`, `gate`, `if`, `do-while`) |
| Python stdlib scripts | Deterministic glue called by workflow `shell` steps; read `.specify/workflows/runs/<run_id>/inputs.json` so user text never hits the shell |
| Bundle + own catalogs | One version across all components; `check-release.py` fails CI on drift |
| Reuse | Upstream `speckit.converge`; upstream `bug` extension declared as a bundle dependency |

Verified on 1.0.13: the installed `speckit-specify` skill is runtime preamble + delegation preamble +
unmodified upstream body.

## Flows

- **Feature:** resolve input → (branch from issue) → specify → *spec gate* → plan → *plan gate* →
  tasks → analyze → implement → converge loop (≤5; detects appended tasks by hashing `tasks.md`) →
  documentation → finish.
- **Bugfix:** bug.assess → *gate* → bug.fix → bug.test → requires `verified` → finish.
- **Quick:** quick-plan → *gate* → quick-implement → self-fixing quick-review (FAIL ⇒ use Feature
  Flow) → doc-check → finish.

## Worth keeping

- Composition via prepend presets; two-preset trick for stacking.
- Documentation model: Layer 1 root `AGENTS.md`; Layer 2 nested `AGENTS.md` / `docs/architecture`
  (contracts, ADRs); Layer 3 strategy / risks / AI debt register. Content is *observed* or
  *guideline* (`<!-- GUIDELINE -->`); guideline-vs-code conflicts stop and go to a human as
  bug / stale guideline / tech debt.
- Finish: PR context gathering, PR-template discovery, conventional commit prefix by flow type,
  `Closes #N`.
- Per-step model routing (`model.config.json`, project root overrides preset copy).
- Shell-safety rule (pass only `run_id` to scripts) and release consistency checks.

## Caveats for speckit-aisdlc

- Finish **deletes `specs/<feature>/`** — conflicts with D-004.
- Runtime preamble applies to **interactive** use too — conflicts with D-005.
- GitHub-only: `gh` issues/PRs, hardcoded `--base main`, `git add -A`; no Jira.
- Disables the `git` extension; branches are `feature/<issue>-<slug>`.
- CI never installs Spec Kit; upgrade safety is untested.
- Depends on engine internals: run directory layout, `inputs.json`, `state.json` written after the
  last step (finish warns that deleting the run dir crashes the engine).
- Runtime scripts are not declared in `preset.yml`; they work only because preset install copies the
  whole package.
- `project-init` writes full template rewrites into `.specify/templates/overrides/`, which then drift
  from upstream.
- Installed individually rather than via the bundle, both presets get priority 10, so preamble order
  isn't guaranteed.
- Stale README details (`2.1.0` pin, "review drives fix", "four workflows"); Windows unsupported.
