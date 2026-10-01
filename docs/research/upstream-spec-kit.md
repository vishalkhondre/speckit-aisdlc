# Upstream Spec Kit — research notes

Source: github/spec-kit. Verified 2026-10-01 by installing `specify-cli` **1.0.13** from PyPI and
initialising a fresh project. The *Public contract* section (issue #6) was pinned on 2026-10-01 from
the `v1.0.13` tag (`f1a548a`); links below point at that tag. "Documented" means stated in upstream
docs; "source" means read in the code only — treat source-only behaviour as *not* contract.
Reviewed by `software-architect`: `docs/reviews/2026-10-01-upstream-contract-software-architect.md`
(findings A1–A9 applied).

## Current shape

- Install: `uv tool install specify-cli`; init: `specify init <dir> --integration <key>`.
- Commands are delivered to agents as **skills** with hyphenated names, e.g. `/speckit-specify`.
  Manifests still use dotted names (`speckit.specify`).
- Three processes: SDD in core (constitution → specify → plan → tasks → implement → converge);
  `bug` (assess → fix → test) and `assess` (intake → research → define → shape → decide) are
  bundled extensions you opt into.
- Customization layers: **extensions** add commands, **presets** override or compose templates and
  commands, **workflows** orchestrate steps, **bundles** package all three.
- Bundled extensions in the repo: `agent-context`, `assess`, `bug`, `git`, `github`, `selftest`, `template`.
- In a fresh 1.0.13 `specify init`, the `git` extension was **not** installed; `.specify/extensions.yml`
  had no hooks.

## Extension command naming (verified in `extensions/EXTENSION-API-REFERENCE.md`)

- Command names must match `^speckit\.[a-z0-9-]+\.[a-z0-9-]+$`, i.e. `speckit.{extension-id}.{command}`.
- Aliases follow the same pattern, **must use the extension's own namespace**, and must not shadow
  core or installed extension commands. Short un-namespaced aliases (e.g. `speckit.verify`) are
  therefore not valid in 1.0.
- Community catalog (`extensions/catalog.community.json`): 176 extensions. The ids `verify`,
  `review`, `ship`, `bugfix`, `security-review` are already taken; `sdlc` and `aisdlc` are free.

## Composition (verified with EF on 1.0.13)

- Preset command entries with `strategy: prepend` produce: preset text + untouched upstream body.
- A preset may declare a given command only once; stacking two layers on one command needs two
  presets, ordered by priority.
- A preset install copies the whole package directory into `.specify/presets/<id>/`, including
  undeclared files such as scripts.

## Public contract (pinned at v1.0.13)

### Sources

| Ref | Document |
|---|---|
| [EXT-API](https://github.com/github/spec-kit/blob/v1.0.13/extensions/EXTENSION-API-REFERENCE.md) | Extension manifest, hooks, CLI |
| [EXT-DEV](https://github.com/github/spec-kit/blob/v1.0.13/extensions/EXTENSION-DEVELOPMENT-GUIDE.md) | Extension manifest field guide |
| [EXT-REF](https://github.com/github/spec-kit/blob/v1.0.13/docs/reference/extensions.md) | `.specify/extensions.yml` and hook fields |
| [PRE-REF](https://github.com/github/spec-kit/blob/v1.0.13/docs/reference/presets.md) | Preset CLI, resolution stack, strategies |
| [PRE-ARCH](https://github.com/github/spec-kit/blob/v1.0.13/presets/ARCHITECTURE.md) | Strategy × file-type matrix, command registration |
| [PRE-PUB](https://github.com/github/spec-kit/blob/v1.0.13/presets/PUBLISHING.md) | `preset.yml` incl. `requires.extensions` |
| [PRE-SCAF](https://github.com/github/spec-kit/blob/v1.0.13/presets/scaffold/preset.yml) | Annotated `preset.yml` |
| [WF-REF](https://github.com/github/spec-kit/blob/v1.0.13/docs/reference/workflows.md) | Workflow CLI, overlays, slots, expressions, run state |
| [WF-README](https://github.com/github/spec-kit/blob/v1.0.13/workflows/README.md) | Step types and fields, error handling, `context.*` |
| [WF-ARCH](https://github.com/github/spec-kit/blob/v1.0.13/workflows/ARCHITECTURE.md) | Engine model, resume semantics |
| [WF-PUB](https://github.com/github/spec-kit/blob/v1.0.13/workflows/PUBLISHING.md) | `workflow.yml` schema and validation rules |
| [BUN-REF](https://github.com/github/spec-kit/blob/v1.0.13/docs/reference/bundles.md) | Bundle CLI, install/refresh semantics |
| [BUN-EX](https://github.com/github/spec-kit/blob/v1.0.13/bundles/bugfix/bundle.yml), [BUN-DEV](https://github.com/github/spec-kit/blob/v1.0.13/examples/bundles/developer/bundle.yml) | `bundle.yml` examples |
| [UPGRADE](https://github.com/github/spec-kit/blob/v1.0.13/docs/upgrade.md) | Project upgrade path |
| [CHANGELOG](https://github.com/github/spec-kit/blob/v1.0.13/CHANGELOG.md) | 0.7.0 → 1.0.13 |

### Extension manifest (`extension.yml`, `schema_version: "1.0"`) — documented [EXT-API], [EXT-DEV]

- `extension`: `id` (`^[a-z0-9-]+$`), `name`, `version` (strict `X.Y.Z`, no pre-release), `description`
  (<200 chars), `author`, `repository`, `license`; optional `homepage`.
- `requires`: `speckit_version` (PEP 440 specifier, no spaces, e.g. `>=1.0.0,<2.0.0`); optional `tools`
  (`name`, `version`, `required`), `commands`, `scripts`.
- `provides`: `commands` (`name` = `speckit.<ext-id>.<cmd>`, `file`, `description`, `aliases` in the same
  namespace, must not shadow core or installed commands); `templates` and `scripts` (plain slug names,
  **always `replace`** — a `strategy` key is a `ValidationError`); `config` (`name`, `template`,
  `required`). Because extensions rank **above core** in resolution, an extension template that shares a
  core name (e.g. `spec-template`) silently replaces it — a hard-rule-2 trap.
- Top-level `hooks` (see below), `events` (agent runtime events, see below), `tags`, `defaults`.
- At least one of `provides.commands|templates|scripts`, `hooks`, `events` is required.
- Config layers: manifest `defaults` → `.specify/extensions/<id>/<id>-config.yml` →
  `<id>-config.local.yml` (gitignored) → env `SPECKIT_<EXT>_<KEY>` (for us `SPECKIT_AISDLC_*`).
  This is a **documented convention, not an engine service**: [EXT-DEV] tells commands to do the merge
  themselves (its example uses `yq`/`jq`). aisdlc's own scripts must implement it, and a missing
  `yq`/`jq`/Python is a failure mode.
- Command bodies: `$ARGUMENTS`; `scripts:` frontmatter with `{SCRIPT}`; and the
  `__SPECKIT_COMMAND_<NAME>__` token, rendered per integration, for referring to another command
  (needed so aisdlc commands can point at each other on both slash-command and skills agents) [EXT-DEV].
  `provides.scripts[].runtimes` is informational only.
- Python classes (`ExtensionManager`, `HookExecutor`, …) are documented in [EXT-API] but are
  engine API, not something an extension can call at runtime — hard rule 3 applies.

### Preset manifest (`preset.yml`, `schema_version: "1.0"`) — documented [PRE-SCAF], [PRE-PUB], [PRE-ARCH]

- `preset`: `id`, `name`, `version`, `description`, `author`, `repository`, `license`.
- `requires`: `speckit_version`; optional `extensions` — bare id or `{id, version, required}`. Without a
  required extension the preset still installs and silently falls through to core; declaring it makes
  `preset add` say so (added in 1.0.4, #4250). A missing, stale or version-mismatched dependency is
  a **warning, not a failure** — the install still succeeds [PRE-PUB].
- `provides.templates[]` (all file kinds live in this one list): `type` (`template` | `command` |
  `script`), `name`, `file`, `description`, optional `replaces`, optional `strategy`.
- Duplicate `name`+`type` entries are rejected (#4191) → one preset can compose a given command only
  once; stacking needs a second preset.

**Strategies** [PRE-ARCH]:

| Strategy | Templates | Commands | Scripts |
|---|---|---|---|
| `replace` (default) | ✓ | ✓ | ✓ |
| `prepend` | ✓ | ✓ | — |
| `append` | ✓ | ✓ | — |
| `wrap` (`{CORE_TEMPLATE}`; scripts `$CORE_SCRIPT`) | ✓ | ✓ | ✓ |

Composition is recursive across the stack. Resolution order, highest first:
`.specify/templates/overrides/` → presets by `priority` (lower wins; ties alphabetical by id) →
extensions by priority → core. Preset commands may target core commands and installed extension
commands (`speckit.<ext>.<cmd>`); commands for a non-installed extension are skipped.

**Materialisation** [PRE-REF]: templates and scripts are resolved at use time; **commands are resolved
at install time** and written into the *active* integration's directory only. Post-install/removal
reconciliation recomputes affected commands; `specify integration use|switch` rescaffolds presets for
the new integration. `specify integration upgrade` re-registers presets after refreshing core files
(source: `integrations/command_upgrade.py`), so a composed command picks up the new upstream body.
`preset disable` affects templates/scripts only — registered commands stay until `preset remove`.
`preset update` is remove-then-add with no rollback.

### Hooks (command lifecycle) — documented [EXT-API], [EXT-REF]

- Events (core command templates surface all of these):
  `before_|after_` × `specify`, `plan`, `tasks`, `implement`, `analyze`, `checklist`, `clarify`,
  `constitution`, `taskstoissues`, and also `converge` (present in the templates, missing from the
  API reference list).
- Hook fields: `command`, `priority` (≥1, default 10), `optional` (default `true`), `prompt`,
  `description`, `condition`; the registry adds `enabled`. An event takes one mapping or a list.
- **Protocol:** registered into `.specify/extensions.yml`. Each core command *template* instructs the
  agent to read that file and, per hook: optional → print a suggestion; mandatory
  (`optional: false`) → print `EXECUTE_COMMAND: <command>` and invoke it, waiting for the result.
  Execution is therefore **agent-interpreted prose**, not engine code — every integration that runs
  core command templates "supports" it, with LLM-level reliability.
- **Caveats (documented):** templates do **not** evaluate `condition` — hooks with a non-empty
  condition are *skipped*; templates surface hooks in YAML order and **ignore `priority`**;
  `auto_execute_hooks` is reserved and unused. Upstream docs conflict here: [EXT-API] says hooks run by
  ascending priority, [EXT-REF] says templates ignore it — the templates are what actually runs. Extension commands (e.g. `bug.*`) define no events.
- **Agent runtime events** (`events:` manifest key; canonical `session_start`, `pre_tool_use`,
  `post_tool_use`, `user_prompt_submit`, `stop`, `session_end`; added 0.15.0–0.16.0, #3704/#3934) install
  native agent hooks via a generated `.specify/events.py`. [EXT-DEV] only names the `events` key; the
  event names and schema are source-only (`src/specify_cli/events/`). **Not yet a contract to build on.**

### Workflow definition (`workflow.yml`, `schema_version: "1.0"`) — documented [WF-PUB], [WF-README], [WF-REF]

- `workflow`: `id`, `name`, `version`, `author`, `description`; optional default `integration`, `model`.
- `requires`: `speckit_version`, `integrations.any: [...]` — **advisory only**, no sandbox.
- `inputs.<name>`: `type` (`string` | `number` | `boolean`), `required`, `default`, `prompt`, `enum`.
- `steps[]`: unique `id` (no `:`), `type` (default `command`), optional `continue_on_error` (literal bool).

| Step type | Key fields |
|---|---|
| `command` | `command`, `input.args`, `integration`, `model`, `integration_args`, `integration_options` |
| `prompt` | `prompt`, `integration`, `model`, `timeout` (source: default 300 s, undocumented for prompt steps) |
| `shell` | `run`, `timeout` (default 300 s), `output_format: json` → `output.data`; env `SPECKIT_WORKFLOW_DIR` |
| `init` | `here`/`project`, `integration`, `script`, `force`, `preset` |
| `slot` | `name`; no-op unless filled by an overlay `replace` |
| `gate` | `message`, `options`, `on_reject` (`abort` \| `skip` \| `retry`), `show_file`, `verdict_input` |
| `if` / `switch` | `condition` + `then`/`else`; `expression` + `cases`/`default` |
| `while` / `do-while` | `condition` + `steps`, `max_iterations` |
| `fan-out` / `fan-in` | per-item `step`, `max_concurrency`; `wait_for` |

- **Expressions:** `{{ … }}` with `inputs.*`, `steps.<id>.output.*`, `item`, `context.run_id`,
  `context.workflow_dir`; comparisons, `and/or/not`, `in`; filters `default`, `join`, `contains`, `map`,
  `from_json`. Plain string substitution, **no shell escaping** — constrain anything reaching a `run`
  field with `enum`, keep unconstrained text out of `run`.
- **Command dispatch:** a `command` step runs the integration CLI non-interactively with the slash
  invocation `/speckit.<cmd> <args>` (or skill form); if the CLI is not installed or does not support
  dispatch, the step fails. Only `exit_code` is documented and usable: `stdout`/`stderr` exist but are
  empty because dispatch streams to the terminal (full capture is "a planned enhancement" in source);
  `prompt` steps likewise. Results must flow through files, or `shell` steps with
  `output_format: json`. `integration_args`/`integration_options` are documented but only
  `docker-agent` accepts them; every other integration rejects them — not a portable lever.
- **Gates:** pause in non-TTY runs; `specify workflow resume <run_id> [--input k=v]`.
  `verdict_input` binds a decision to an input so CI or a resume can supply it.
- **Run state** (documented layout): `.specify/workflows/runs/<run_id>/` with `state.json`,
  `inputs.json`, `log.jsonl`; statuses `created|running|completed|paused|failed|aborted`.
  `specify workflow run|resume|status --json` is the supported machine interface. `SPECKIT_WORKFLOW_RUN_ID`
  pre-sets the run id (#2742). Resume is top-level-step granular: a pause inside `if`/`while` re-runs
  the whole parent block.
- **Overlays (0.13.2+) and slots (1.0.5+):** `.specify/workflows/overlays/<workflow-id>/*.yml` with
  `insert_before|insert_after|replace|remove` on step ids; lower priority wins (applied last); anchors
  resolve recursively but not inside fan-out templates; survive workflow updates; cannot change
  inputs, metadata or `requires`. This is the documented way for a *project* to customise a workflow
  it did not write. **No package type can ship an overlay** — they are added only by
  `specify workflow overlay add`; bundles provide `extensions|presets|steps|workflows` only.
- **Custom step types** (`specify workflow step add`, step catalogs) exist but the official step
  catalog is empty and the format is thinly documented — avoid for now.
- Install: `specify workflow add <dir|zip|tgz|url|id>`; a directory install keeps companion files
  (scripts), exposed through `context.workflow_dir` / `SPECKIT_WORKFLOW_DIR`.

### Bundle manifest (`bundle.yml`, `schema_version: "1.0"`) — documented by example [BUN-REF], [BUN-EX]

- `bundle`: `id`, `name`, `version`, `role`, `description`, `author`, `license`.
- `requires`: `speckit_version`, `tools`, `mcp`.
- `provides`: `extensions[]` (`id`, `version`), `presets[]` (`id`, `version`, `priority`, `strategy`),
  `steps[]`, `workflows[]` (`id`, `version`).
- Components resolve through bundled components, installed components, or the active
  extension/preset/workflow/step catalogs — **the bundle catalog only points at the bundle artifact**.
  A bundle referencing our own components needs our catalogs added, or a local bundle directory.
- `bundle install` is idempotent by **id, not version**; changing a recorded bundle needs
  `--refresh` (local source) or `bundle update` (catalog). Failed install is best-effort rollback;
  failed refresh is not rolled back. `bundle build` produces a zip; `bundle validate` checks references.
- An optional top-level `integration` pins the bundle to one integration and aborts install on a
  mismatch (source: `bundles/manifest.py`) — aisdlc should stay integration-agnostic.
- `builtin://community` bundle catalog is discovery-only: users must add aisdlc's own catalog to install
  by id. Version pins apply only at install/refresh time.
- Preset **priority is set by the bundle**, which fixes EF's "both presets at priority 10" problem when
  installed via the bundle — but not when installed individually.

### D-010 — can the engine apply behaviour per run only?

**No.** There is no first-class, documented mechanism (verified in source and docs). A `command` step
passes only the slash invocation plus `input.args` text to the agent CLI and sets no environment variable
or flag the command body can see (`workflows/step/command/__init__.py`, `integrations/base.py:dispatch_command`).
A preset preamble is materialised at install time and applies to every invocation. Per-step
`integration_args`/`integration_options` work only for `docker-agent`.

Options, each with its risks (see the review, finding A1):

1. **Gates in the workflow, commands untouched** (what D-010 already prefers). Approvals are `gate`
   steps; `verdict_input` lets CI pre-answer them. *Risk:* in non-interactive dispatch an agent that asks
   a question usually ends its turn and exits 0, so the step reads `COMPLETED` with no work done. Each
   command step needs a following check (e.g. a `shell` step asserting the expected file in
   `specs/<feature>/`).
2. **Argument marker.** The workflow passes a fixed token in `input.args` and a *conditional* preamble
   says "only if the arguments start with this token, do not ask questions". *Risks:* the token is part
   of `$ARGUMENTS` and can leak into spec text or branch names unless the preamble strips it; hooks
   (`EXECUTE_COMMAND`) and chained commands do not inherit it; it is still preamble text in every
   composed body, so it meets D-010 only under a looser reading of "per run". Prompt-level, not enforced.
3. **`prompt` steps** that state the unattended rule inline, then name the command. *Risks:* default
   300 s timeout (source-only) kills long commands; the prompt must hard-code the invocation syntax
   (`/speckit-…`, `$speckit-…`, `/skill:…`) per integration.
4. **Launcher environment.** The agent subprocess inherits the environment of whoever runs
   `specify workflow run`, and `SPECKIT_INTEGRATION_<KEY>_EXTRA_ARGS` appends flags to every dispatched
   agent CLI (#2596). A CI job can set agent-native flags or an `SPECKIT_AISDLC_*` variable; manual use is
   unaffected. *Risks:* set by the launcher, not by `workflow.yml`; flags are agent-specific; the generic
   behaviour is source and CHANGELOG only, so adopting it adds an internal dependency.

Choosing 2, 3 or 4 means a new decision that refines D-010. The user decides.

### Changes 0.7 → 1.0.13 that matter to aisdlc — [CHANGELOG]

| Version | Change | Impact |
|---|---|---|
| 0.7.1 → 0.10.0 | `--ai` deprecated (#2218); `--ai`, `--ai-commands-dir`, `--ai-skills` **removed** in 0.10.0 (#2872) | Use `--integration` only |
| 0.7.5, 0.8.0 | `wrap` (#2189), then `prepend`/`append` composition (#2133) | Our core mechanism needs ≥ 0.8.0 |
| 0.8.16–0.9.4 | `context.run_id` (#2664), `SPECKIT_WORKFLOW_RUN_ID` (#2742), `continue_on_error` (#2663), JSON run/resume/status (#2814) | Workflow glue we can rely on |
| 0.10.0 | `git` extension opt-in, `--no-git` removed (#2873); per-event hook lists with priority (#2798) | Branch creation is not core; aisdlc must not assume it |
| 0.11.x–0.12.x | `speckit.converge` (#3001), `from_json` (#2961), `output_format: json` (#2963), `specify bundle` (#3070), fan-out `max_concurrency` (#3224) | Converge is reusable; bundles become our distribution unit |
| 0.13.2–0.14.x | Workflow resolver and overlays (#3557 onward) | Overlays = customisation without forking a workflow |
| 0.15.0–0.16.2 | Agent runtime `events` (#3704, #3934); `verdict_input` (#3725); Copilot defaults to skills (#3976); extension `provides.templates`/`scripts` (#4012); constitution resolved at command time (#3984) | `verdict_input` matters for unattended runs (D-010) |
| 1.0.0 | Duplicate preset `name`+`type` entries rejected (#4191) | One composition per command per preset |
| 1.0.4–1.0.9 | Preset `requires.extensions` (#4250); workflow `slot` (#4352, 1.0.5); bundle changes need explicit refresh (#4477); aliases may not shadow core (#4558); first-party `bugfix`/`assess` bundles (#4504) | Slots + overlays = organisation-preset extension point for workflows |
| 1.0.13 | Bundled `github` extension for `taskstoissues` (#4488) | Candidate to depend on for tracker work |

No item in 1.0.0–1.0.13 is marked breaking, but contract-tightening validation ships as `fix:` entries
(#4191, #4477, #4558), any of which can reject a previously valid manifest. With releases every few days,
hard rule 6 needs the floor version **and** latest tested on every aisdlc change, plus a scheduled job
against latest. Also note: `specify integration upgrade` **refuses** a commands↔skills layout change
while preset command overrides are installed (source: `integrations/command_upgrade.py`) — an upstream
default switch such as Copilot moving to skills (#3976) means remove presets, upgrade, re-add.

### Implications for aisdlc (for the capability map; not decisions)

- **Minimum version:** if aisdlc uses workflow `slot` and preset `requires.extensions`, the floor is
  1.0.5; otherwise 1.0.0 is a natural line. Candidate range `>=1.0.5,<2.0.0` (the user decides).
- **Organisation-preset extension points available upstream:** preset templates/commands (stack above
  ours by lower priority) and the extension config convention (`aisdlc-config.yml`, env
  `SPECKIT_AISDLC_*`, merged by our scripts). Workflow overlays and `slot` steps are **project-level**:
  an organisation must deliver them by a documented `overlay add` setup step, its own workflow that
  wraps ours, or a preset that composes the commands our workflow calls.
- **Naming guardrail:** aisdlc extension templates and scripts use `aisdlc-`-prefixed names; any change
  to a core template goes through a preset with `prepend`/`append`/`wrap`. CI can assert this.
- **Workflow outputs:** route outcomes through files or `shell` JSON output, never command `stdout`.
- **Hooks are weak for mandatory behaviour** (agent-interpreted, conditions skipped, priority ignored).
  Prefer workflow steps or preset composition for anything that must happen.
- **Workflow run files are now documented**, so reading `inputs.json` from a `shell` step (EF's
  pattern) is within the contract; `state.json` *internals* are not specified field-by-field —
  use `specify workflow status --json` instead.

## Internal dependencies

Engine internals speckit-aisdlc relies on that are not part of the documented contract. Keep this
list empty, or justify each entry.

aisdlc has no code yet. Design assumptions already made, each to keep (and test), avoid, or decide:

| Behaviour (source-only) | Plan |
|---|---|
| `specify integration upgrade` re-registers preset commands, so composed commands pick up the new upstream body | **Keep and test in CI:** install the floor version with aisdlc, upgrade, run `integration upgrade`, assert the composed body contains the new upstream text |
| Preset install copies the whole package directory, including undeclared files | **Avoid:** declare scripts as `type: script` |
| Env inheritance into dispatched agents; `SPECKIT_INTEGRATION_<KEY>_EXTRA_ARGS` | Only if D-010 option 4 is chosen |
| Which integrations support CLI dispatch (no documented list) | Test in CI for each supported integration |
| `prompt` step default timeout of 300 s | Only if D-010 option 3 is chosen; set `timeout` explicitly |

Keep off this list entirely: the agent runtime `events` schema, `state.json` field layout, custom step
types, and any `specify_cli` Python import.
