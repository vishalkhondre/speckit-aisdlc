# Architecture review: aisdlc bundle skeleton (#16)
Date: 2026-10-01 · Reviewer: software-architect

## Verdict
APPROVE WITH CHANGES. The skeleton follows the hard rules, and its manifests are correct for Spec Kit 1.0.5 and 1.0.13. Fix the preset priority (A1) before anything installs at 0.0.1. Turn the 0-owned-components install path, version drift and validate behaviour (A2, A3, A6) into explicit #19/#20 acceptance criteria.

## Checklist
| # | Check | Result | Evidence |
|---|---|---|---|
| 1 | No vendoring or forking | pass | Only manifests, one command, one template, one workflow and one shell script. No Spec Kit code in the repo. Install goes through documented `specify` CLI commands (`scripts/dev/install-local.sh:22-25`). |
| 2 | Compose, never replace | pass | `preset/preset.yml:22-26` adds one new `aisdlc-brief` template. It has no `replaces`, no core name, and no command entries. The extension has no `templates`. No upstream file is copied. |
| 3 | Public contract only | concern | All CLI verbs are documented (`extension add --dev`, `preset add --dev`, `workflow add --dev`, `bundle install <path>`, per docs/reference/*.md at v1.0.13). One undocumented point: the comment in `bundle/bundle.yml:26-29` relies on bundle `strategy` being recorded but not applied. That is true in source (`bundles/manifest.py:210`, `records.py:202`, `command_info.py:142`), but `docs/reference/bundles.md` never says what `strategy` does. See A4. |
| 4 | Upgrade safety and version range | concern | The range `>=1.0.5,<2.0.0` matches D-024 in all four manifests. Nothing yet enforces that they stay aligned, and Spec Kit does not check pins for components that are already installed (`docs/reference/bundles.md:98`). CI (#19) is not in place yet. See A3 and A6. |
| 5 | Durable specs, interactive commands | pass | Nothing deletes anything. The setup placeholder (`extension/commands/speckit.aisdlc.setup.md:13-21`) only tells the user something and stops. There is no global preamble (D-004, D-005). |
| 6 | Generic and de-branded | pass | Author is "speckit-aisdlc contributors". The only names are `aisdlc` and `SPECIFY` (the env var in the script). The repository URL is the project's own. |
| 7 | Extension points | concern | The preset is at priority 10 (`bundle/bundle.yml:25`, and the default for `preset add --dev`). That is the same default an organisation preset gets. On a tie, the alphabetical id decides which wins (`presets/_registry.py:228-231`). See A1. |
| 8 | Simplicity | pass | This is the minimum each package type accepts. The preset needs at least one `provides.templates` entry (`presets/_manifest.py:166-191`), so the placeholder template is justified. |
| 9 | Failure modes | concern | `install-local.sh` cannot be re-run on a project that already has aisdlc. Running `bundle validate` online outside a project fails. `bundle build` needs a README. See A5, A6 and A7. Not needed: `git`, `gh`, a tracker. |

**Manifest field check (verified against v1.0.13 source and docs; the 1.0.5 behaviour is what the calling session observed):**
- **`extension.yml`:**
  - id matches `^[a-z0-9-]+$`.
  - Version is strict X.Y.Z.
  - Description is about 105 characters (the limit is 200).
  - The PEP 440 range has no spaces.
  - The command name is `speckit.aisdlc.setup` with no `aliases` key (D-026).
  - The optional `homepage` and `tags` are valid.
- **`preset.yml`:**
  - `requires.extensions: ["aisdlc"]` uses the bare-id form, which is valid from 1.0.4.
  - The template entry has `type`, `name`, `file` and `description`.
  - It has no `strategy` key, so it defaults to `replace`. That is correct for a new name with nothing beneath it.
- **`workflow.yml`:**
  - All required metadata is present.
  - The input is typed and is not interpolated into `run`.
  - Step id `skeleton` contains no `:`.
- **`bundle.yml`:**
  - All required `bundle.*` fields are present (`manifest.py:172-184`).
  - Components are pinned with semver versions.
  - The preset has an integer `priority` and a valid `strategy`.
  - There is no top-level `integration`, so the bundle works with any integration.
  - This matches upstream's example bundles (`examples/bundles/*/bundle.yml`, which also use `priority: 10, strategy: "append"`).

## Findings

### A1 — aisdlc preset priority ties with organisation presets (severity: medium)
**Fact:**
- Presets resolve by `(priority, id)`, and the lower value wins (`src/specify_cli/presets/_registry.py:228-231`).
- aisdlc's preset is at 10 (`bundle/bundle.yml:25`, and the default for `preset add --dev` in `install-local.sh:23`).
- An organisation preset added with the default priority is also 10. Whether it ranks above aisdlc then depends only on its id sorting before `aisdlc`: `acme-*` would win, `org-*` would lose.
- The capability map says organisation template sections are "ranked above aisdlc" (`docs/research/capability-map.md:118`). The same tie decides the order of composed `append` sections once phase 4 composes core commands.

**Why now:** a bundle records preset priority as owned metadata, and changing it later needs `--refresh` (`docs/reference/bundles.md:74`). At 0.0.1 with no users, changing it costs nothing.

**Suggested change:**
- Give aisdlc a deliberately weak priority, e.g. `priority: 50`, in `bundle.yml`.
- Pass the same value in `install-local.sh` (`preset add --dev ... --priority 50`).
- Document in the organisation-preset guide: "use a priority below 50".

**Optional (judgement):** in phase 4, move aisdlc-owned *new* templates such as `aisdlc-brief` into the extension's `provides.templates`. Extensions rank below every preset, so any organisation preset overrides them regardless of priority. The aisdlc preset would then hold only compositions of core commands. Keep the placeholder until the first composition exists, because a preset needs at least one entry.

### A2 — Bundle with 0 owned components is a label, not a distribution unit (severity: medium)
**Fact (from `docs/reference/bundles.md`):**
- A local bundle supplies the manifest, not the component payloads (line 82).
- Install is idempotent by id, and pins are enforced only when a component is installed or refreshed (line 98).
- Refresh does not adopt independently installed components (line 80).
- `remove` uninstalls only the components the bundle contributed (line 106).
- The official and community extension catalogs do not contain aisdlc, and the community catalog is discovery-only (`extensions/__init__.py:3905-3913`).

**Consequences of the `--dev` + `bundle install` path:**
- `bundle remove aisdlc` leaves all three components in place.
- `bundle update` and `--refresh` change nothing.
- `bundle list` reports 0 components.
- The bundle's version pins are never checked.

**Acceptable for now?** Yes, for development and CI of the skeleton. The issue's Done criterion ("installs ... from a local directory") is met only in the sense of "via `scripts/dev/install-local.sh`". Say this in the PR body and amend the criterion wording, so nobody later reads it as `bundle install <dir>` working on its own (it does not: "Extension 'aisdlc' not found in any catalog").

**What #20 should do:**
- Per release, publish:
  - an extension zip, a preset zip and a workflow artifact;
  - one catalog JSON per kind (extension, preset, workflow);
  - a bundle catalog entry pointing at a `bundle build` zip.
- Host them on GitHub release assets or Pages (catalog URLs must be https, or http on localhost: `is_https_or_localhost_http`, `extensions/__init__.py:41,4416`).
- The documented user path is:
  1. `specify extension catalog add --install-allowed`, and the same for preset, workflow and bundle catalogs;
  2. `specify bundle install aisdlc`.
- On that path the bundle owns its components, so `update` and `remove` work.
- It is four catalog adds, which is clunky but entirely within the public contract. Consider a one-line documented setup snippet rather than a wrapper CLI (D-002).

**What #19 should do:**
- Test both paths on the floor version and latest:
  - (a) the dev path, `install-local.sh`;
  - (b) the release path, with catalogs served from `python -m http.server` on localhost and built artifacts.
- On (b), assert `bundle list --json` shows 3 owned components and that `bundle remove` removes them.

### A3 — Version and naming consistency is not enforced by Spec Kit; CI must lint it (severity: medium)
**Fact:**
- `bundle validate` checks only structure and that references resolve. It does not compare the bundle's pins with installed versions (`bundles/validator.py:35-60`, `references.py:18-61`).
- Install skips present components without comparing versions.

So a drift goes unnoticed: for example, `extension.yml` at 0.0.2 while `bundle.yml` pins 0.0.1.

**Suggested #19 lint, a deterministic stdlib script, D-036.** Assert:
- **Versions and ranges:**
  - the extension, preset and workflow `version` equal `bundle.version` and every pin in `bundle.yml`;
  - all four `speckit_version` strings are identical (AGENTS.md:98 states the rule, but nothing checks it).
- **Naming guardrails** (`upstream-spec-kit.md` § Implications):
  - every extension command matches `^speckit\.aisdlc\.[a-z0-9-]+$` and has no `aliases` key (D-026);
  - extension templates and scripts, and preset entries of type `template`/`script` that have no `replaces`, are named `aisdlc-*`;
  - every preset entry targeting a core or non-aisdlc name has `strategy` in {prepend, append, wrap}, so it never uses `replace` (hard rule 2);
  - `bundle.yml` has no top-level `integration`;
  - the workflow id appears in `bundle.yml`.

### A4 — Reliance on bundle `strategy` being informational is source-only (severity: low)
**Fact:**
- `strategy` is required by validation (`bundles/manifest.py:210-214`).
- It is otherwise only stored (`records.py:202-203`) and displayed (`command_info.py:142-154`).
- The docs mention it only as displayed metadata (`docs/reference/bundles.md:56,74`).

**Risk:** if upstream ever applies a bundle-level strategy to all of a preset's entries, `append` would apply to `aisdlc-brief` (a new template with no base). It would also apply to future mixed-strategy compositions.

**Suggested change:**
- Add a row to "Internal dependencies" in `docs/research/upstream-spec-kit.md`: "bundle `presets[].strategy` is not applied; per-entry strategies in `preset.yml` are authoritative — keep and test".
- In CI, assert `specify preset resolve aisdlc-brief` output equals `preset/templates/aisdlc-brief.md`.
- Optional: ask upstream to document the field's semantics.

The comment at `bundle/bundle.yml:26-28` is accurate.

### A5 — `install-local.sh` is not re-runnable (severity: low)
**Fact:**
- `extension add` refuses an already-installed id without `--force` (`extensions/__init__.py:2126-2130`, `extensions/command_add.py:24`).
- The preset manager raises "already installed" (`presets/_manager.py:395`), and `preset add` has no `--force` option (`presets/command_add.py:133-149`).
- With `set -e` (line 13), a second run aborts at line 22.
- After a version bump, `bundle install` without `--refresh` also rejects the changed record (`bundles.md:74`).

This is not a CI blocker if each job uses a fresh project.

**Suggested change:** either state "fresh project only" in the header, or add an update mode:
- remove workflow, then preset, then extension (reverse order, because the preset requires the extension);
- re-add all three;
- run `bundle install --refresh`.

Upstream preserves top-level `*-config.yml` files across extension removal and update (`extensions/__init__.py:2809-2820`), and D-035's `local-config.yml` matches that suffix. So a reinstall does not lose user config. (Verified by reading the code, not by running it.)

### A6 — `bundle validate` result depends on where it runs (severity: low; a #19 blocker if missed)
**Fact:**
- References resolve against the project found from the manifest's directory, or else the cwd (`bundles/command_validate.py:35`).
- Online, a component that is neither installed nor in a reachable catalog is an **error** (`references.py:106-114`).
- `specify bundle validate --path bundle/`, run from the repo root or a fresh project with network access, therefore fails on all three references.
- It passes only inside a project where `install-local.sh` has already run, or with `--offline` (warnings only).

**Suggested #19 order:**
1. `specify init` into a temp dir;
2. `install-local.sh <tmp>`;
3. `cd <tmp> && specify bundle validate --path $REPO/bundle`;
4. assert exit code 0.

Optionally also run `--offline` from the repo root as a structural check.

### A7 — `bundle build` requires `bundle/README.md` (severity: low; blocks #20)
**Fact:** `bundles/packager.py:45-49` refuses to build without a README next to `bundle.yml`. The `bundle/` directory has only `bundle.yml`.

**Suggested change:** add a short neutral README now, or make it part of #20. Include `bundle build` in the #19 matrix so the problem shows up before release.

### A8 — Smaller gaps against the issue checklist (severity: low)
- **Scripts:** the checklist item "scripts declared with aisdlc- names" is deferred to #17 by a comment (`extension/extension.yml:24-26`). That is reasonable, since declaring a script with no file adds nothing. Record the deferral in the PR and issue.
- **Workflow input:** `inputs.description` is `required: true` with no default (`workflows/aisdlc-feature/workflow.yml:15-18`). CI on a non-TTY runner must pass `--input description=...`. Confirm this in #19 rather than relying on prompting.
- **Workflow rename:** the workflow id and directory are placeholders until #5. Renaming changes a bundle-owned id, which is a remove-plus-add for any installed bundle. That is harmless before the first release, so settle #5 before #20.
- **Extension description:** it advertises "start, verify and ship", which do not exist yet. This is cosmetic, but do not publish it to a catalog until they exist.
- **AGENTS.md repo map:** the additions (`AGENTS.md:84-88, 98-99`) are accurate and short. Paths match the tree. I read the working-tree file only; `git diff` was not run.

## Sources
- Files reviewed:
  - `/home/user/speckit-aisdlc/extension/extension.yml`
  - `/home/user/speckit-aisdlc/extension/commands/speckit.aisdlc.setup.md`
  - `/home/user/speckit-aisdlc/preset/preset.yml`
  - `/home/user/speckit-aisdlc/preset/templates/aisdlc-brief.md`
  - `/home/user/speckit-aisdlc/workflows/aisdlc-feature/workflow.yml`
  - `/home/user/speckit-aisdlc/bundle/bundle.yml`
  - `/home/user/speckit-aisdlc/scripts/dev/install-local.sh`
  - `/home/user/speckit-aisdlc/AGENTS.md`
- Decisions: D-002, D-004, D-005, D-024, D-026, D-027, D-035, D-036 (`docs/context/DECISIONS.md`); `docs/research/upstream-spec-kit.md` (Bundle manifest, Internal dependencies); `docs/research/capability-map.md:109-139`.
- Upstream v1.0.13 (local clone at `/tmp/claude-0/-home-user-speckit-aisdlc/ae074815-d58f-5380-b8b1-bd69ca751933/scratchpad/spec-kit`):
  - `docs/reference/bundles.md` (lines 56, 70-82, 98, 106, 144); upstream URL: https://github.com/github/spec-kit/blob/v1.0.13/docs/reference/bundles.md
  - `docs/reference/extensions.md:171-189` (catalog resolution, `--install-allowed`)
  - `src/specify_cli/bundles/manifest.py:19, 172-214, 255-275`
  - `src/specify_cli/bundles/validator.py:35-60`
  - `src/specify_cli/bundles/references.py:18-127`
  - `src/specify_cli/bundles/command_validate.py:27-41`
  - `src/specify_cli/bundles/packager.py:45-49`
  - `src/specify_cli/bundles/primitives.py:1-60, 197-215, 285-306`
  - `src/specify_cli/presets/_registry.py:201-231`
  - `src/specify_cli/presets/_manifest.py:165-191`
  - `src/specify_cli/presets/command_add.py:133-149`
  - `src/specify_cli/presets/_manager.py:395`
  - `src/specify_cli/extensions/__init__.py:2126-2130, 2809-2820, 3905-3913, 4416`
  - `examples/bundles/*/bundle.yml`
- Calling session's runtime findings on 1.0.5 and 1.0.13 (validate passes, skill registration, `preset resolve`, `workflow run`): reported to me, not re-run by me. Everything I verified myself was by reading the 1.0.13 source and docs; I did not read 1.0.5 source.
