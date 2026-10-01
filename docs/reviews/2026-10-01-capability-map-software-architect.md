# Architecture review: capability map (#9)
Date: 2026-10-01 · Reviewer: software-architect

Target: `docs/research/capability-map.md` (status: proposed). I checked it against AGENTS.md hard rules 1–7, D-001…D-028, `docs/research/upstream-spec-kit.md` and the prior-art sweep. Upstream facts come from the Spec Kit `main` clone at `d2ddd91` (pyproject `1.0.14.dev0`, CHANGELOG head `[1.0.13] - 2026-09-29`). URLs below point at tag `v1.0.13`. Source line numbers come from the clone and may differ slightly from the tag. Labels used below:
- **[verified]**: I read it in upstream docs or source.
- **[source-only]**: I read it in code only, so it is not contract.
- **[judgement]**: my opinion.

## Verdict
APPROVE WITH CHANGES. The map follows the hard rules and puts mandatory behaviour in workflow steps. However, the MVP feature flow cannot run end to end as written. Four things need fixing first:
- the converge loop has no machine-readable way to know when to stop;
- `analyze` produces no artifact to check;
- appending to `converge` contradicts converge's own rules;
- the config loader cannot be "stdlib only" and also read YAML.

## Checklist
| # | Check | Result | Evidence |
|---|---|---|---|
| 1 | No vendoring or forking | pass | Map lines 16–23 and 45–65 build only on extension, preset, workflow and bundle packages (D-002, D-003). |
| 2 | Compose, never replace | concern | No `replace` anywhere. Preset `append` onto core `converge` (row 2, line 46) contradicts converge's "only write is tasks.md" rule (A3). |
| 3 | Public contract only | concern | All mechanisms used are documented. Three need attention: state mirroring via `workflow status --json` cannot see gate choices (A5); the "defaults template supplied by a preset" config option has no documented machine-readable resolver (A4); preset composition onto aisdlc commands may not survive `extension update`, which I found in source only (A6). |
| 4 | Upgrade safety | concern | CI design (row 18) is sound. It lacks three tests: preset-on-aisdlc-command after an aisdlc update (A6), the converge-loop end signal (A1), and a way to run workflows in CI without a live agent (A8). |
| 5 | Durable specs, interactive commands | pass | Ship keeps specs (row 7, D-004). No never-ask preamble (line 63; D-005, D-023). |
| 6 | Generic and de-branded | pass | No organisation names. Jira, Confluence and SAFe appear only as examples of what an organisation preset could do (lines 88, 92). |
| 7 | Extension points | concern | Templates, constitution and review areas: fine. Tracker via `append`: not workable (A6). Config defaults: unresolved (A4). Workflow slots: correctly marked project-level (line 91). |
| 8 | Simplicity | concern | Docs reconciliation and `analyze` add weight to the MVP (A2, A8). `quick-review` could merge into `review` (A9). Remediate as "no command" is good (row 9). |
| 9 | Failure modes | concern | Not covered: loop runs out of iterations (A1), `.specify/feature.json` collisions and who owns the spec directory (A7), missing `gh` or non-GitHub tracker in phase 4 (A6), a local config file that is not gitignored (A4). |

## Findings

### A1: The converge loop has no machine-readable end condition, and running out of iterations passes silently (severity: high)

**Facts [verified]:**
- A `command` step exposes only `exit_code` (`upstream-spec-kit.md:171-176`).
- Converge reports `converged` or `tasks_appended` only in the session. When nothing is left to do it leaves `tasks.md` "byte-for-byte unchanged" ([converge.md](https://github.com/github/spec-kit/blob/v1.0.13/templates/commands/converge.md), "Operating Constraints" and Step 7). So the outcome a `do-while` condition needs is never written to a file.
- The D-023 check ("expected artifact exists") cannot tell three cases apart: converged, a turn that stopped to ask a question, or a turn that did nothing.

**Facts [source-only]:** when `max_iterations` runs out, the engine simply leaves the loop and carries on with the next step. It does not fail or pause (`src/specify_cli/workflows/engine.py` ~1406–1440). A pause inside a `do-while` re-runs the whole loop on resume ([workflows/ARCHITECTURE.md](https://github.com/github/spec-kit/blob/v1.0.13/workflows/ARCHITECTURE.md) ~l.76).

**Why it matters:** row 4 (line 48) and the feature flow (line 30) rely on this loop. As written, the loop either always runs the maximum number of times or stops after the first pass, and a feature that never converged still flows on to verify and ship.

**Suggestion [judgement]:** an aisdlc `shell` step after converge, reporting through `output_format: json`. It hashes `tasks.md` before and after converge, or counts unchecked `- [ ]` items in the latest `## Phase N: Convergence` section. The loop condition reads that output. After the loop, add a `shell` check that fails, or a `gate`, when the loop ran out of iterations. Keep gates out of the loop body because of the resume re-run behaviour.

### A2: `analyze` in the MVP feature flow writes no artifact and cannot be checked (severity: high)

**Facts [verified]:** `analyze` is "STRICTLY READ-ONLY … Output a Markdown report (no file writes)" ([analyze.md](https://github.com/github/spec-kit/blob/v1.0.13/templates/commands/analyze.md) l.58, 164). Command-step stdout is empty in dispatch (`upstream-spec-kit.md:173-175`).

**Why it matters:** in the workflow at line 30, analyze's findings disappear. No D-023 artifact check is possible for it, which breaks design rule 1 (line 14).

**Suggestion [judgement]:** remove `analyze` from the unattended feature workflow, and document it as a manual command. If you want a check before implement, follow analyze with a `gate`, accepting that the human has only the terminal stream to read.

### A3: Appending to core `converge` contradicts its body; composed text is as reliable as a hook (severity: high)

**Facts [verified]:** row 2 (line 46) appends a "write decisions.md / brief.md" section to `specify`, `plan`, `tasks`, `implement` and `converge`. Converge's body says "The command's **only** write is appending a new `## Phase N: Convergence` section to `tasks.md`" (converge.md, "Operating Constraints"). An appended section ordering other writes contradicts the upstream text in the same prompt. Appending to core commands is otherwise documented ([presets/ARCHITECTURE.md](https://github.com/github/spec-kit/blob/v1.0.13/presets/ARCHITECTURE.md) strategy table).

**Judgement:** text appended by a preset is read and followed by the agent, the same way hook instructions are. If decisions and briefs are mandatory (D-013, D-027), the map's own rule 1 calls for an artifact check after each command. If they are best-effort, the map should say so.

**Suggestion:**
- Do not compose `converge`. Write the converge brief from the aisdlc `shell` step in A1, or from `verify`.
- For the other four commands, either add an artifact check for `brief.md`, or label decisions and briefs "best-effort on manual runs, checked in workflows".

### A4: Config loader: stdlib-only cannot parse YAML; local-override filename is not gitignored; the preset-defaults option has no public resolver (severity: medium)

**Facts [verified]:**
- Row 17 (line 61) proposes `aisdlc-config.yml`, merged by "an aisdlc Python script (stdlib only, no `yq`/`jq`)". The Python standard library has no YAML parser. `specify-cli` itself depends on `pyyaml>=6.0` (pyproject.toml l.12), but that lives in the `uv tool` environment, not in the `python3` a `shell` step calls. That last point is my inference and I did not test it.
- Upstream docs name the local override `<ext>-config.local.yml` ([EXTENSION-API-REFERENCE.md](https://github.com/github/spec-kit/blob/v1.0.13/extensions/EXTENSION-API-REFERENCE.md) "Config Layers"). The managed `.specify/.gitignore` ignores `extensions/*/local-config.yml` instead ([shared_infra.py@v1.0.13](https://github.com/github/spec-kit/blob/v1.0.13/src/specify_cli/shared_infra.py), `SPECIFY_GITIGNORE_CONTENT`; [docs/reference/core.md](https://github.com/github/spec-kit/blob/v1.0.13/docs/reference/core.md) l.61). So `aisdlc-config.local.yml` would be committed by default.
- The line 87 option (a defaults template a preset supplies by name) needs a machine-readable way to resolve templates:
  - `specify preset resolve` prints Rich text and has no `--json` (`src/specify_cli/presets/command_resolve.py`) [source-only].
  - The only JSON resolver is core's `.specify/scripts/python/resolve_template.py --json`. Core's constitution command calls it through its frontmatter, but it is not documented for third parties.

**Suggestion [judgement]:**
- Pick a config format the loader can actually parse: JSON, a documented flat YAML subset with a tiny parser, or an explicit `pyyaml` requirement.
- Read both local filenames, or document a `.gitignore` line.
- If the preset-defaults option is kept, record `resolve_template.py` under "Internal dependencies" (hard rule 3) with a CI test. Otherwise keep config strictly per project, which is what line 87 already defaults to.

### A5: State mirroring via `workflow status --json` cannot record gate choices; expressions can, more simply (severity: medium)

**Facts [verified]:**
- The `status --json` payload has `run_id`, `workflow_id`, `status`, `current_step_id`, `current_step_index`, `error`, `created_at`, `updated_at`, and `steps: {id: status}` (`src/specify_cli/workflows/command_status.py` l.47–59 [source-only]; [docs/reference/workflows.md](https://github.com/github/spec-kit/blob/v1.0.13/docs/reference/workflows.md) l.27–55 [verified]).
- A gate's choice is not in it. Approve and reject with `on_reject: skip` both report `COMPLETED` ([workflows/README.md](https://github.com/github/spec-kit/blob/v1.0.13/workflows/README.md) l.354–369).
- The choice is available directly as `{{ steps.<gate>.output.choice }}`, along with `{{ context.run_id }}` (README l.360, 420).
- Steps inside loops get engine-generated ids like `<loop>:<id>:<n>` (workflows.md l.224; engine.py l.1419), so any mirroring script must expect them.

**Suggestion [judgement]:** after each gate, add a `shell` step that appends one line, built from expressions, to `specs/<f>/.aisdlc/` (JSONL merges more easily, as the sweep notes). Keep `status --json` only for run-level status. Constrain anything that reaches `run` (no shell escaping; `upstream-spec-kit.md:169-170`).

### A6: The tracker extension point (preset composes aisdlc `start`/`ship`) is possible but fragile (severity: medium)

**Facts [verified]:**
- Presets can compose installed extension commands ([presets/ARCHITECTURE.md](https://github.com/github/spec-kit/blob/v1.0.13/presets/ARCHITECTURE.md) l.107). Upstream tests cover `append` on an extension command (`tests/specify_cli/presets/test_manager_commands.py` l.3081).
- `wrap` resolves the extension's own command body (`presets/_manager_commands.py` l.52–67) [source-only].
- Bundle install order is extensions, then presets (`bundles/manifest.py` l.83) [source-only].
- Commands are materialised at install time ([docs/reference/presets.md](https://github.com/github/spec-kit/blob/v1.0.13/docs/reference/presets.md) l.200).

**Source-only, not tested:** I found no preset reconciliation in the extension add/update path (`src/specify_cli/extensions/`, no preset references outside comments). An `extension update aisdlc` may therefore overwrite an organisation preset's composed `speckit.aisdlc.ship` with aisdlc's plain body.

**Judgement:** `append` cannot remove behaviour. If ship's body runs `gh pr create` and writes `Closes #N`, a Jira preset can only add to that, not replace it. `wrap` would amount to replacing the command in practice.

**Suggestion:**
- In phase 4, route tracker operations in `start` and `ship` through one config key (`tracker: github | none`). The `none` mode means "no issue link, print the PR command". This also covers a missing `gh`.
- Make the preset extension point "compose the tracker section" rather than "rewrite ship".
- Add a CI case: org-style preset composing `speckit.aisdlc.ship` → `extension update aisdlc` → assert the composed text is still present. If it fails, document "re-add presets after aisdlc updates" or have upgrades go through `bundle update`.

### A7: Feature start and the spec directory: who owns `.specify/feature.json`? (severity: medium)

**Facts [verified]:** core `specify` always creates the spec directory and writes `.specify/feature.json`. It auto-numbers under `specs/` unless the user explicitly supplies `SPECIFY_FEATURE_DIRECTORY` "via environment variable, argument, or configuration". The text says "The spec directory and file are always created by this command, never by the hook" ([specify.md](https://github.com/github/spec-kit/blob/v1.0.13/templates/commands/specify.md) step 3). `feature.json` is gitignored, local to one checkout, and is not tied to the branch. `SPECIFY_FEATURE_NO_PERSIST` exists for concurrent runs ([core.md](https://github.com/github/spec-kit/blob/v1.0.13/docs/reference/core.md) l.55–61).

**Why it matters:** row 1 (line 45) lists `.specify/feature.json` as start's output, but `specify` will overwrite it. The workflow's artifact checks need to know `specs/<f>` deterministically.

**Suggestion [judgement]:**
- `start` computes the feature directory and the workflow passes it to `specify` in `input.args` (an `enum`-safe or slug-only value).
- Every artifact check reads the directory from one source.
- Drop `feature.json` from start's outputs.
- Document that two runs in one checkout need `SPECIFY_FEATURE_NO_PERSIST`, or separate worktrees.

### A8: Phase 4 MVP is not minimal and misses two pieces it needs (severity: medium)

**Missing [judgement, building on verified facts]:**
1. The loop end signal and the check after the loop (A1).
2. A check on verify's verdict: a `shell` step that fails the run unless `verification.md`'s verdict line passes. Running the project's checks is deterministic, so it is better done as a `shell` step writing JSON that `speckit.aisdlc.verify` then maps to requirements, rather than having the LLM run the tests.
3. A way to exercise the feature workflow in CI. Command steps need a dispatch-capable agent CLI (`upstream-spec-kit.md:171-173`, 298), so hard rule 6's "exercise the bundle" needs a decision in phase 3: a stub integration, or validate and run only the deterministic steps.

**Could defer:**
- Docs reconciliation (row 6) is the heaviest new command and is not needed to get a PR out.
- `analyze` (A2).

A smaller MVP: start → specify → gate → plan → gate → tasks → implement → converge loop → verify (+ verdict check) → ship, with decisions and briefs. This would also settle open question 1 (line 107): review can stay in phase 5.

### A9: Simplicity: fewer commands are possible (severity: low)

**Judgement:**
- `quick-review` (row 12, line 56) overlaps `review` (row 8). One `review` command with a quick scope would remove a command and a template, and would carry the constitution check (open question 3).
- `quick-implement` is justified: core `implement` requires `tasks.md` (check-prerequisites `--require-tasks`, implement frontmatter).
- `route` (row 13) is chat-only and reads nothing, so it is cheap. It could be a short section in the README or wiki instead of a command until users ask for it.
- Folding secure into review (row 10) and remediate into converge (row 9) are good simplifications.

### A10: Workflow slots and overlays are described correctly; two caveats (severity: low)

**Facts [verified]:**
- `type: slot` exists and an unfilled slot completes as `skipped` (workflows.md l.321–347).
- Only `specify workflow overlay add` can install an overlay (l.231–234).
- Overlay anchors resolve inside `steps` blocks, but not inside fan-out templates (l.222).
- The floor of 1.0.5 matches D-024.

**Caveats [judgement]:**
- A slot filled by a `command` step has no D-023 artifact check unless the overlay adds one. Document that.
- For "pre-ship" behaviour, a preset prepending to `speckit.aisdlc.ship` is packageable, while the slot is not. Offer both and say when to use each.

### A11: Bugfix and quick flows' per-feature files are not consistent with D-013 (severity: low, phase 5)

**Facts [verified]:** upstream `bug` writes to `.specify/bugs/<slug>/` (`extensions/bug/commands/speckit.bug.assess.md` l.7, 25–31). Line 36 says every flow writes per-feature decisions and briefs, and D-013 puts them under `specs/<feature>/`. The quick flow writes `specs/<f>/plan.md` without `spec.md`, while core `converge` and other commands require `spec.md` (`--require-spec`). The sweep lists "does `specs/tiny/` confuse feature detection" as untested.

**Suggestion:** before phase 5, decide where bugfix decisions and briefs live, and whether quick-flow directories carry a minimal `spec.md`.

## Sources
- Map under review: `docs/research/capability-map.md` l.14–23, 30–36, 45–65, 73–78, 85–92, 105–113. Context: `AGENTS.md` l.13–32; `docs/context/DECISIONS.md` D-004, D-005, D-011, D-013, D-014, D-023, D-024, D-026–D-028; `docs/research/upstream-spec-kit.md` l.80–84, 113–124, 126–146, 167–190, 286–302; `docs/reviews/2026-10-01-prior-art-sweep-prior-art-researcher.md` l.221–226, 281.
- Upstream at v1.0.13:
  - https://github.com/github/spec-kit/blob/v1.0.13/templates/commands/converge.md
  - https://github.com/github/spec-kit/blob/v1.0.13/templates/commands/analyze.md
  - https://github.com/github/spec-kit/blob/v1.0.13/templates/commands/specify.md
  - https://github.com/github/spec-kit/blob/v1.0.13/presets/ARCHITECTURE.md
  - https://github.com/github/spec-kit/blob/v1.0.13/docs/reference/presets.md
  - https://github.com/github/spec-kit/blob/v1.0.13/docs/reference/workflows.md
  - https://github.com/github/spec-kit/blob/v1.0.13/workflows/README.md
  - https://github.com/github/spec-kit/blob/v1.0.13/workflows/ARCHITECTURE.md
  - https://github.com/github/spec-kit/blob/v1.0.13/docs/reference/core.md
  - https://github.com/github/spec-kit/blob/v1.0.13/extensions/EXTENSION-API-REFERENCE.md
  - https://github.com/github/spec-kit/blob/v1.0.13/src/specify_cli/shared_infra.py (gitignore content checked at the tag)
- Source-only (clone `d2ddd91`): `src/specify_cli/workflows/engine.py` ~l.1380–1440, `workflows/command_status.py` l.47–59, `workflows/step/do_while/__init__.py`, `presets/_resolver.py` l.507–680, `presets/_manager_commands.py` l.22–67, `presets/command_resolve.py`, `bundles/manifest.py` l.83, `extensions/__init__.py` (registration path, ~l.1510–1570), `tests/specify_cli/presets/test_manager_commands.py` l.3081, `pyproject.toml` l.12, `extensions/bug/commands/speckit.bug.assess.md`.
