# Phase 3 issues (drafts)

Drafted by Claude chat from the accepted capability map (D-029). Under D-017, **Claude Code creates these
as GitHub issues** (milestone *Phase 3 · Skeleton and compatibility CI*), then deletes this file in the same
PR. Order is the suggested build order; each issue lists its dependencies.

---

## 1. Bundle skeleton: extension, preset, feature workflow stub, bundle manifest

**Labels:** `build` · **Capability map:** phase 3 · **Depends on:** —

Create the four package manifests so aisdlc installs on a stock Spec Kit, with almost no behaviour yet.

- [ ] `extension.yml`: id `aisdlc`, `speckit_version: ">=1.0.5,<2.0.0"` (D-024), one command
      `speckit.aisdlc.setup` (placeholder body), no aliases (D-026), scripts declared as `type: script`
      with `aisdlc-` names.
- [ ] `preset.yml`: id `aisdlc`, `requires.extensions: [aisdlc]`; no command compositions yet.
- [ ] Feature workflow stub: inputs, one `shell` step, valid against `specify workflow` validation;
      placeholder id until #5 names the workflows.
- [ ] `bundle.yml` listing the extension, preset and workflow at one version.
- [ ] Repo layout recorded in `AGENTS.md` "Repo map".

**Done when:** `specify bundle validate` passes, and the bundle installs into a fresh project on Spec Kit
1.0.5 and on the latest release, from a local directory.

---

## 2. Configuration loader (`aisdlc-config.py`)

**Labels:** `build` · **Capability map:** #2 · **Decisions:** D-035 · **Depends on:** 1

- [ ] Documented flat key–value YAML subset (comments, strings, booleans, integers, one level of lists
      if needed — document exactly what is supported and reject the rest with a clear error).
- [ ] Stdlib-only parser; no PyYAML, `yq` or `jq`.
- [ ] Merge order: built-in defaults → `.specify/extensions/aisdlc/aisdlc-config.yml` →
      `.specify/extensions/aisdlc/local-config.yml` → env `SPECKIT_AISDLC_*`.
- [ ] Prints the merged config as JSON (for workflow `shell` steps with `output_format: json`).
- [ ] Initial keys: `branch_pattern`, `base_branch`, `tracker` (`github` | `none`), `checks` (list of
      commands), `converge_max_iterations`, `size_rule_max_files`.
- [ ] Unit tests (Python `unittest`), including malformed input.

**Done when:** tests pass in CI and the format is documented in the repo.

---

## 3. `speckit.aisdlc.setup` command

**Labels:** `build` · **Capability map:** #1 · **Depends on:** 1, 2

- [ ] Interactive: asks only for values not already set (D-023 rule for aisdlc commands), writes
      `aisdlc-config.yml`.
- [ ] Confirms `local-config.yml` is covered by `.specify/.gitignore`.
- [ ] Warns if `specs/` is gitignored (durable specs, D-004).
- [ ] Documented as the organisation-defaults extension point: an organisation preset `append`s its
      defaults to this command.

**Done when:** running it in a fresh project produces a valid config that the loader (issue 2) reads.

---

## 4. Compatibility CI

**Labels:** `build` · **Capability map:** #3 · **Decisions:** D-024, D-036, hard rule 6 · **Depends on:** 1

GitHub Actions workflow, on every PR and nightly:

- [ ] Matrix: Spec Kit floor `1.0.5` and latest release (resolve "latest" from PyPI at run time).
- [ ] Install the bundle into a fresh project for at least two integrations.
- [ ] Assert every aisdlc composition of a core command still contains the upstream body.
- [ ] Naming guardrail: aisdlc templates and scripts use the `aisdlc-` prefix; no aliases; no
      `replace` strategy on core commands.
- [ ] `specify integration upgrade` keeps composed commands current.
- [ ] An organisation-style test preset composing an aisdlc command survives `extension update aisdlc`
      (architect finding A6).
- [ ] Deterministic workflow steps and aisdlc scripts run against fixture projects (D-036).
- [ ] Nightly failure is visible (failed run on the Actions tab; optionally an issue).

**Done when:** the matrix is green on `main`, and a deliberately broken composition makes it fail.

---

## 5. Release consistency checks

**Labels:** `build` · **Capability map:** phase 3 ("plus release checks") · **Depends on:** 1, 4

- [ ] One version across extension, preset, workflow and bundle manifests, checked in CI.
- [ ] A manual release workflow that builds the package archives and publishes a GitHub release.
- [ ] Idea from Extended Flow's release checks (D-025: our own implementation, nothing copied).

**Done when:** a dry-run release on a branch produces installable archives and the check fails on a
version mismatch.

---

## 6. Confirm the supported Spec Kit range (D-024)

**Labels:** `decision`, `needs-decision` · **Depends on:** 4

D-024 set `>=1.0.5,<2.0.0` provisionally. With compatibility CI running, confirm or adjust the floor (it
depends on whether phase 4 workflows use `slot` steps) and record the result as a decision.

**Done when:** a decision entry confirms or replaces D-024.
