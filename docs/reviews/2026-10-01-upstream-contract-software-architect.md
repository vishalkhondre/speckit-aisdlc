# Architecture review: Public contract pinned at Spec Kit v1.0.13 (issue #6)
Date: 2026-10-01 · Reviewer: software-architect

Reviewed: `/home/user/speckit-aisdlc/docs/research/upstream-spec-kit.md`, lines 39–247 ("Public contract (pinned at v1.0.13)" and "Internal dependencies"). I checked it against the local `v1.0.13` clone at `/tmp/claude-0/-home-user-speckit-aisdlc/ae074815-d58f-5380-b8b1-bd69ca751933/scratchpad/spec-kit` (shortened to `SK/` below).

## Verdict
APPROVE WITH CHANGES. The section is accurate on almost every claim I spot-checked. It covers the issue #6 checklist and classifies things carefully. But the D-010 analysis leaves out one real per-process lever and understates the risks of options 1–3. Several "extension point" claims hide a delivery gap or a convention that aisdlc must implement itself. And the "Internal dependencies" list should be seeded now, not left as "none yet".

## Checklist
| # | Check | Result | Evidence |
|---|---|---|---|
| 1 | No vendoring or forking | pass | The document only describes and links to upstream at a pinned tag. Nothing is copied. |
| 2 | Compose, never replace | concern | The strategy matrix is correct (`SK/presets/ARCHITECTURE.md:52-54`). It does not warn that extension-provided templates always `replace` and rank above core, so a name collision is a full replacement (A5). |
| 3 | Public contract only | concern | The documented/source split is mostly right. Some items are presented as contract when they are source-only or empty in practice: command-step `stdout` (A2), the config layering engine (A3), re-registration on `integration upgrade` (A6), and whole-directory preset copy (A7). |
| 4 | Upgrade safety | concern | Proposed range `>=1.0.5,<2.0.0` and a min+latest matrix are sound. Missing: the commands↔skills layout-change refusal while presets are installed (A6), and validation tightenings shipped as patch "fixes" (A9). |
| 5 | Durable specs / interactive commands | concern | Nothing deletes specs. The D-010 options do not install a global never-ask preamble, but option 2 is still prompt text prepended to every invocation, so it needs a user decision that amends D-010's condition (A1). |
| 6 | Generic and de-branded | pass | No organisation names. Examples use `SPECKIT_AISDLC_*` and neutral ids. |
| 7 | Extension points | concern | It lists the right upstream mechanisms. Workflow overlays are project-local and cannot be shipped by a preset, extension or bundle (A4). Config layering is a convention, not an engine feature (A3). |
| 8 | Simplicity | N/A (research) | Not a design. The recommendation to prefer workflow steps or composition over hooks is the simpler path and is well supported. |
| 9 | Failure modes | concern | Not covered: a command that asks a question during non-interactive dispatch exits 0 with no work done (A1). Also not covered: `requires.extensions` only warns, the prompt-step 300 s timeout, and community bundle catalogs being discovery-only (A8). |

## Findings

### A1 — The D-010 option set is incomplete and understates its risks (severity: high)
**Verified:**
- The main claim holds. `CommandStep` passes only the invocation and `args`, and sets no env or flag (`SK/src/specify_cli/workflows/step/command/__init__.py:136,255-262`). `dispatch_command` builds `/speckit.<stem> <args>` and calls `subprocess.run` with no `env=` (`SK/src/specify_cli/integrations/base.py:368-371,466-489`). The workflow package only reads `SPECKIT_WORKFLOW_RUN_ID` (`engine.py:1035`) and never sets env.

**Missed:**
- **A per-process lever already exists.** The agent subprocess inherits the environment of whoever ran `specify workflow run`. Separately, `SPECKIT_INTEGRATION_<KEY>_EXTRA_ARGS` appends flags to every dispatched agent CLI in that process (`base.py:315-350`, applied in `build_exec_args` at `base.py:1103`). Twenty integrations call it.
  - A CI job could set agent-native flags (for example a system-prompt-append flag) or an `SPECKIT_AISDLC_*` variable that aisdlc's own scripts read and report back. Manual use is unaffected.
  - This is the closest thing to "applied per run rather than to every invocation". It is set by the launcher, not by `workflow.yml`.
  - The generic behaviour is source and CHANGELOG only (#2596). Docs show it only by example for two integrations (`SK/docs/reference/integrations.md:21,36`). The flags are agent-specific. If adopted it belongs under "Internal dependencies".
- Per-step `integration_args`/`integration_options` are documented, but only `docker-agent` accepts them. Every other integration rejects them (`base.py:264-291`, plus `docker_agent/__init__.py` as the only override). So they are not a portable per-step lever. The document should say so explicitly, since it is the obvious "per-run" candidate a reader will ask about.

**Understated risks in options 1–3 (judgement, grounded in source):**
- **Option 1.** In non-interactive dispatch, an agent that asks a question usually ends its turn and exits 0. The step is then `COMPLETED` (`command/__init__.py:169-183`) and the workflow moves on with missing artefacts. Any workflow following option 1 needs a check after each command step (for example a `shell` step that verifies the expected file in `specs/<feature>/`). Note this in the option.
- **Option 2.** The marker travels inside `$ARGUMENTS`, which core commands treat as user input. For example, `specify` derives the feature description and branch from it, so the token can leak into spec text or branch names unless the preamble strips it. Hooks invoked through `EXECUTE_COMMAND` and commands chained via `__SPECKIT_COMMAND_*__` do not inherit the marker. It is also still preamble text in every composed command body, so it meets D-010 only under a looser reading of "applied per run".
- **Option 3.** `prompt` steps have a default `timeout` of 300 s (`SK/src/specify_cli/workflows/step/prompt/__init__.py:102`; not documented for prompt steps, only for shell steps in `SK/workflows/README.md:155,170`), so long commands are killed. The prompt also has to hard-code the invocation syntax (`/speckit-…`, `$speckit-…`, `/skill:…`) because workflows get no `__SPECKIT_COMMAND_*__` rendering. The cost is portability across integrations, not just "not using command dispatch".

**Suggested change:**
- State plainly that the answer to D-010's open question is **no**.
- Add the env / `EXTRA_ARGS` lever as option 4, labelled source-level and agent-specific.
- Add the risks above to each option.
- Note that adopting option 2, 3 or 4 means a new decision that refines D-010. The user decides.

### A2 — Command and prompt step `stdout`/`stderr` are empty in practice (severity: medium)
The document lists command-step output as `exit_code, stdout, stderr, dispatched`.
- `dispatch_command` streams by default and returns `stdout: ""` (`base.py:461-481`).
- The step docstring says full capture is "a planned enhancement" (`command/__init__.py:21-26`).
- Prompt steps also return `""` (`prompt/__init__.py:246-250`).
- Upstream documents only `exit_code` (`SK/workflows/README.md:270,323`).

Mark `exit_code` as the only documented and usable output. Workflows must pass results through files or `shell` steps with `output_format: json`. This affects how aisdlc routes outcomes (for example verify → remediate).

### A3 — Config layering is a convention aisdlc must implement, not an engine service (severity: medium)
The document presents "defaults → `<id>-config.yml` → `.local.yml` → `SPECKIT_<EXT>_<KEY>`" as if the engine provides it. EXT-DEV says "In your command, load config with layered precedence", and its example is a shell script using `yq`/`jq` (`SK/extensions/EXTENSION-DEVELOPMENT-GUIDE.md:379-403`). The engine's `ConfigManager` (`SK/src/specify_cli/extensions/__init__.py:4522-4660`) is Python-internal. It serves `HookExecutor` conditions, which command templates skip anyway (`SK/templates/commands/plan.md:32-34`).

Rephrase as "documented convention; aisdlc's scripts must implement the merge". Flag the tool dependency (`yq`/`jq` or Python) as a missing-tool failure mode. This is the main organisation-preset extension point for tracker and branch pattern (D-011, D-012), so it matters.

### A4 — Workflow overlays cannot be shipped by any package type (severity: medium)
Overlays live only under `.specify/workflows/overlays/<id>/` and are added with `specify workflow overlay add` (`SK/docs/reference/workflows.md:128-132,199-202`). Bundle `provides` has `extensions|presets|steps|workflows`, with no overlays (`SK/examples/bundles/developer/bundle.yml:17-31`). Slots are no-ops unless an overlay fills them, so the same limit applies.

"Workflow overlays and slots" are therefore a project-level extension point. An organisation preset package cannot deliver them through `preset add` or `bundle install`. Record this in the implications. Distribution options for the capability map:
- a documented `overlay add` step in the organisation's setup;
- an organisation workflow that wraps ours;
- an organisation preset that composes the commands the workflow calls.

### A5 — Extension templates and scripts always `replace` and sit above core (severity: medium)
The document records that extension `templates`/`scripts` are always `replace` (`SK/extensions/EXTENSION-API-REFERENCE.md:136-141`). Resolution order puts extensions above core (`SK/docs/reference/presets.md:206`). So an aisdlc extension template that happens to share a core name (for example `spec-template`) silently replaces the core template. That breaks hard rule 2.

Add a guardrail to the implications: aisdlc extension templates and scripts must use `aisdlc-`-prefixed names. Any change to a core template goes through a preset with `prepend`/`append`/`wrap`. CI could assert this.

### A6 — Upgrade path for composed commands is source-only and has a refusal case (severity: medium)
**Verified:**
- `integration upgrade` re-registers presets after a same-layout refresh (`SK/src/specify_cli/integrations/command_upgrade.py:341`).
- It **refuses** a commands↔skills layout change, and the Kilo legacy directory migration, while preset command overrides are installed. The user must remove the presets, upgrade, then re-add them (`command_upgrade.py:99-145,147-180`).
- `docs/upgrade.md` mentions neither behaviour; it lists only `integration upgrade` + `extension update` (`SK/docs/upgrade.md:15`).

Two consequences:
- The core promise that "composed commands pick up the new upstream body" rests on undocumented behaviour. List it under Internal dependencies and test it in CI: install an older floor version with aisdlc, upgrade `specify-cli`, run `integration upgrade`, then assert the composed body contains the new upstream text.
- An upstream default switch such as Copilot moving to skills (#3976) turns into a manual remove/re-add for aisdlc users. Note this in upgrade safety.

### A7 — Seed "Internal dependencies" now (severity: low)
"None yet" is true for code but hides the design assumptions already made in this section. Proposed entries, each to keep, avoid or test:
- re-registration of preset commands on `integration upgrade` (A6);
- whole-directory preset copy, including undeclared files (document lines 36–37). Not in `SK/docs/reference/presets.md`. Avoid relying on it; declare scripts as `type: script`;
- env inheritance into dispatched agents and `SPECKIT_INTEGRATION_<KEY>_EXTRA_ARGS` semantics, if option 4 is chosen (A1);
- which integrations support CLI dispatch. There is no documented list; it is `requires_cli` plus `build_exec_args` in source (`base.py:1100-1102`);
- the prompt-step default timeout (A1).

Keep the existing "keep off this list" items.

### A8 — Completeness gaps against the issue checklist (severity: low)
- **Extension command bodies:** the `__SPECKIT_COMMAND_<NAME>__` token for cross-command references (`SK/extensions/EXTENSION-DEVELOPMENT-GUIDE.md:277,293-330`) is missing. It is essential for aisdlc commands that point to each other across slash and skills agents. Also missing: `{SCRIPT}`/`scripts:` frontmatter, and `provides.scripts[].runtimes`.
- **Hooks:**
  - The `enabled` registry field is omitted (`SK/docs/reference/extensions.md:265`).
  - Upstream docs contradict each other on ordering. EXT-API says hooks run by ascending priority (`SK/extensions/EXTENSION-API-REFERENCE.md:157`); EXT-REF says templates ignore priority (`SK/docs/reference/extensions.md:267,276`). The document follows the templates, which is correct, but should note the conflict.
  - Agent-runtime event names are only in a newsletter, not in EXT-DEV.
- **Workflows:**
  - `while`/`do-while` `max_iterations` and the prompt-step `timeout`/`model` fields are missing from the step table.
  - Overlay precedence semantics are omitted ("lower wins, applied last", `SK/docs/reference/workflows.md:126`).
  - Overlay anchors are resolved recursively, but fan-out templates are not valid anchors (`workflows.md:190`).
- **Presets:** a missing `requires.extensions` dependency produces a **warning, not a failure** (`SK/presets/PUBLISHING.md:125`). State this as a failure mode.
- **Bundles:**
  - The manifest schema is defined by example plus source (`SK/src/specify_cli/bundles/manifest.py:126`, an optional top-level `integration` mapping). There is no schema reference, so "documented" is generous. Mark it "documented by example".
  - Advise aisdlc to stay integration-agnostic, because a pinned integration aborts install on mismatch (`SK/docs/reference/bundles.md:72`).
  - `builtin://community` is discovery-only (`bundles.md:170-174`). Users will need aisdlc's catalog added to install by id.
  - Version pins apply only at install time (`bundles.md:98`).

### A9 — "No item marked breaking" understates patch-level risk (severity: low)
Literally true, but contract-tightening validation shipped as `fix:` entries in 1.0.x: #4191 (1.0.0), #4477, #4558 (`SK/CHANGELOG.md:139,168,335`). Any of these can reject a previously valid aisdlc manifest. This supports testing the floor version plus latest on every upstream release, and ideally a scheduled job against latest. Say this explicitly as the hard rule 6 rationale.

### Verified as accurate (sample)
- Extension id, version, description, `speckit_version` and command/alias patterns: `SK/extensions/EXTENSION-API-REFERENCE.md:23-125`.
- Rejection of `strategy` on extension templates/scripts: `EXTENSION-API-REFERENCE.md:136-141`.
- Strategy matrix: `SK/presets/ARCHITECTURE.md:52-54`. Resolution order and ties: `SK/docs/reference/presets.md:102,206`. `preset disable` semantics: `presets.md:276`.
- Commands for non-installed extensions are skipped: `ARCHITECTURE.md:107`.
- Hook events, including `converge`: `SK/templates/commands/converge.md:22,246`.
- `EXECUTE_COMMAND` prose, condition skipping and `auto_execute_hooks` reserved: `SK/templates/commands/plan.md:27-95`, `SK/docs/reference/extensions.md:257,270`.
- Run-state layout and statuses: `SK/docs/reference/workflows.md:88,652-656`.
- `verdict_input` semantics: `workflows.md:662-716`.
- Expressions and filters: `workflows.md:586-598`.
- Resume granularity: `SK/workflows/ARCHITECTURE.md:73-77`.
- Bundle idempotency and refresh: `SK/docs/reference/bundles.md:72-98`.
- All 29 CHANGELOG PR references in the change table exist at the stated entries.

## Sources
- `docs/research/upstream-spec-kit.md` (reviewed section, lines 39–247); `AGENTS.md` hard rules 1–7; `docs/context/DECISIONS.md` D-002, D-004, D-005, D-007, D-010, D-011, D-012
- Upstream v1.0.13 (local clone): `extensions/EXTENSION-API-REFERENCE.md`, `extensions/EXTENSION-DEVELOPMENT-GUIDE.md`, `docs/reference/extensions.md`, `docs/reference/presets.md`, `presets/ARCHITECTURE.md`, `presets/PUBLISHING.md`, `docs/reference/workflows.md`, `workflows/README.md`, `workflows/ARCHITECTURE.md`, `workflows/PUBLISHING.md`, `docs/reference/bundles.md`, `docs/reference/integrations.md`, `docs/upgrade.md`, `CHANGELOG.md`, `templates/commands/{plan,converge}.md`, `examples/bundles/developer/bundle.yml`, `bundles/bugfix/bundle.yml`
- Upstream source read to classify source-only behaviour: `src/specify_cli/integrations/base.py`, `src/specify_cli/integrations/command_upgrade.py`, `src/specify_cli/workflows/step/command/__init__.py`, `src/specify_cli/workflows/step/prompt/__init__.py`, `src/specify_cli/workflows/engine.py`, `src/specify_cli/extensions/__init__.py` (ConfigManager), `src/specify_cli/bundles/manifest.py`
- Web equivalents: https://github.com/github/spec-kit/tree/v1.0.13
