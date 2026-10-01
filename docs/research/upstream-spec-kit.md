# Upstream Spec Kit — research notes

Source: github/spec-kit. Verified 2026-10-01 by installing `specify-cli` **1.0.13** from PyPI and
initialising a fresh project. Sections marked *TODO* are next-action #2 in STATUS.md.

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

## TODO — public contract to pin

- Full manifest schemas: extension, preset (strategies: replace / prepend / append), workflow, bundle.
- Hook events and the `EXECUTE_COMMAND` protocol; which integrations support it.
- Workflow engine: step types (`shell`, `command`, `gate`, `if`, `do-while`, `while`, `switch`,
  `fan-out`, `fan-in`, `prompt`), expressions, run-state layout under `.specify/workflows/runs/`.
- Changes and deprecations between 0.7.x and 1.0.x (CHANGELOG).

## Internal dependencies

Engine internals speckit-aisdlc relies on that are not part of the documented contract. Keep this
list empty, or justify each entry.

- *(none yet)*
