# Prior-art review: sweep of 14 candidate capabilities (issue #7)
Date: 2026-10-01 · Reviewer: prior-art-researcher (three parallel runs, combined and spot-checked by the
calling session)

## Summary

Upstream Spec Kit 1.0.13 (latest on PyPI, 2026-09-29) already covers the core of **verify** and
**remediate** through `speckit.converge`. It ships nothing for the other twelve candidates. The
community catalog (176 extensions, 40 presets, 2 workflows, 3 bundles) has at least one entry for every
candidate. Most are single-author packages from 2026; several conflict with hard rule 2 (they replace or
edit core templates). Two catalog entries do not install on 1.0.13 at all.

**Nothing is recommended for ADOPT.** Recommendations:
- **DEPEND** for verify: build on core converge, with `verify-tasks` as an optional dependency.
- **DEPEND (optional) + BORROW** for secure: `threatspec`.
- **BORROW** for the other twelve.

Extended Flow (EF) remains the main source for ship and quick change flow, and BMAD-METHOD for review
triage, retrospective and size-based routing. These are recommendations; the user decides in #10.

## Summary table

| # | Candidate | Recommendation | Best existing option | Source |
|---|---|---|---|---|
| 1 | verify | **DEPEND** — core converge + thin aisdlc layer (run project checks, machine-readable verdict); `verify-tasks` optional | Core `speckit.converge`; `verify-tasks` | `templates/commands/converge.md` @ v1.0.13; https://github.com/datastone-inc/spec-kit-verify-tasks |
| 2 | review | **BORROW** — build `review` | verify-review-ship `review` (design only; does not install), BMAD `bmad-code-review` triage | https://github.com/cadugevaerd/spec-kit-verify-review-ship; https://github.com/bmad-code-org/BMAD-METHOD |
| 3 | secure | **DEPEND (optional) + BORROW** — `threatspec` for threat modelling; diff security review as a reviewer area in aisdlc `review` | `threatspec` | https://github.com/hupe1980/spec-kit-threatspec |
| 4 | remediate | **BORROW** — findings → tasks appended under converge's contract, `implement`, bounded re-check loop | Core converge → implement; EF converge loop | `converge.md` @ v1.0.13; https://github.com/markuswondrak/spec-kit-extended-flow |
| 5 | guard | **BORROW** — deterministic checks in workflow `shell` steps and `gate`s; policy content in organisation presets | `spec-gates` (one policy, same check at agent / git / CI) | https://github.com/schwichtgit/spec-gates |
| 6 | ship | **BORROW** — EF finish minus spec deletion, with tracker interface and configurable base branch | EF `finish` | https://github.com/markuswondrak/spec-kit-extended-flow |
| 7 | deploy | **BORROW (idea only), keep thin or drop** — readiness/record step + organisation hook; no deploy executor | None suitable; upstream says deploy is plain CI | `docs/guides/agentic-sdlc.md` §6 @ v1.0.13 |
| 8 | router | **BORROW** — recommend a route, human confirms at a gate | BMAD `bmad-build` size rule; `gh-triage` "unknown → human" | https://github.com/bmad-code-org/BMAD-METHOD; https://github.com/arrrrny/speckit-extensions |
| 9 | quick change flow | **BORROW** — adapt EF Quick flow without its runtime preamble or spec deletion | EF Quick flow | https://github.com/markuswondrak/spec-kit-extended-flow (`workflows/quick-flow.yml`) |
| 10 | retrospective | **BORROW** — `specs/<feature>/retrospective.md`, evidence-sourced, one destination per lesson | `retrospective` (emi-dm); BMAD `bmad-retrospective` | https://github.com/emi-dm/spec-kit-retrospective |
| 11 | brownfield onboarding | **BORROW** — scout writes a reviewable proposal, core `/speckit.constitution` writes the constitution | EF `project-init`/`documentation-init` (ideas); BMAD `bmad-project-context` | https://github.com/markuswondrak/spec-kit-extended-flow; https://github.com/bmad-code-org/BMAD-METHOD |
| 12 | docs reconciliation | **BORROW** — EF documentation model; DocGuard as optional checker | EF `documentation` / `doc-check`; DocGuard | https://github.com/raccioly/docguard |
| 13 | decision log and handoffs | **BORROW** — `intent`'s append-only `DEC-####` format in `specs/<feature>/decisions.md` | `intent` (Intent Reconciliation) | https://github.com/SuhaibAslam/spec-kit-reconcile |
| 14 | per-feature session state | **BORROW** (DEPEND only if a deep-dive shows a stable, extensible schema) | SpecKit Companion `.spec-context.json` | https://github.com/alfredoperez/speckit-companion |

## Deep-dives (serious contenders only)

### verify-tasks — verify (DEPEND candidate)
- **What it does:** detects tasks marked `[X]` with no real implementation, using five evidence layers.
  It reads converge's `per <source-ref>` tags and runs the named test command as evidence. A new command
  plus optional `after_implement` / `after_converge` hooks; composes with core.
- **Health:** MIT, v1.2.0, last commit 2026-09-15, four commit authors. `speckit_version >=0.12.17`, no
  upper bound. **Installs on 1.0.13** (re-checked).
- **Caveat:** declares the un-namespaced alias `speckit.verify-tasks`. This works only because the
  1.0.13 source accepts free-form aliases, contrary to the docs (see cross-cutting finding 1).
- **Verdict:** good fit as an optional bundle dependency beside core converge, behind our compatibility
  CI.

### threatspec — secure (DEPEND candidate)
- **What it does:** threat modelling, security requirements and their verification. Adds `model`,
  `check` and `converge`. Gaps become "Security Convergence" tasks appended to `tasks.md`. Deterministic
  Python engine (PyYAML only) with SARIF/JSON output, a CI action and a `secure-sdd` workflow with gates.
- **Composes cleanly:** its `threatspec-sdd` preset uses `strategy: "append"` on core `tasks`,
  `analyze`, `converge` and `checklist` (re-checked in `preset.yml`).
- **Health:** MIT, `speckit_version >=1.0.0`, repo v0.2.0 (2026-09-27), catalog lags at 0.1.0, two
  authors, five commits. Its 46 tests pass (1 skipped), per the research run. **Installs on 1.0.13**
  (re-checked).
- **Risks:** very young; seven optional hooks may be noisy beside aisdlc's own steps.
- **Verdict:** strongest secure option; offer it as optional, pinned to a release tag.

### spec-gates — guard (BORROW)
- **What it does:** one `.specify/gates/policy.json`, checked by the same `verify.sh` at the agent, git
  and CI boundaries. A parity test keeps the boundaries in sync, and canaries plant known violations to
  prove the gate still fires.
- **Health:** MIT, v0.3.3, last commit 2026-08-01, one human author.
- **Limits:** the agent boundary writes agent-specific hook config for a single agent. Its README says
  "Verified against Spec Kit v0.12.4".
- **Verdict:** borrow the "one policy, same check everywhere" and canary ideas into workflow `shell`
  steps (D-023). Worth checking whether its git and CI layer could be an optional dependency without
  the agent layer.

### verify-review-ship — review / verify design reference (not a dependency)
- **Good design:** converge owns completeness and review owns diff quality. Per-area read-only
  reviewers; a source fingerprint marks evidence stale; a learning gate routes each lesson to one
  destination.
- **Health:** MIT, one author, 17 tests pass.
- **Disqualified as a dependency:** **does not install on 1.0.13** at v0.4.2 or HEAD — "Invalid script
  name 'source-fingerprint.sh': must be lowercase alphanumeric with hyphens only" (re-checked by
  install). Its `ship` merges to the primary branch and pushes, with no PR step.
- **Verdict:** design reference for review, verify and retrospective.

### Extended Flow `finish` and Quick flow — ship and quick change flow (BORROW basis)
- **finish:** gathers PR context and finds the PR template (`scripts/resolve-pr-template.py`). It sets
  the commit prefix by flow type and always writes `Closes #<issue>`.
- **Quick flow:** quick-plan → plan gate → quick-implement → self-fixing quick-review (FAIL means "use
  the Feature Flow") → doc-check → finish.
- **Conflicts to remove when adapting:**
  - finish deletes `specs/<feature>/` (D-004);
  - `gh pr create --base main`, `git add -A`, GitHub only (D-011);
  - quick commands depend on the preset's runtime preamble (D-005) and on `.specify/feature.json` written
    by `init-quick.py`, so the extension cannot be taken without the preset.
- **Licence gap:** EF declares MIT in `README.md` and `extension.yml` (author "Markus Wondrak"), but the
  repository has **no LICENSE file** (re-checked with `git ls-files`). See cross-cutting finding 3.

### SpecKit Companion — per-feature session state (possible DEPEND)
- **What it does:** writes `specs/<NNN>/.spec-context.json` with `currentStep`, `status`, an append-only
  `history[]`, `decisions[]` and `nextCommand`. Writes are atomic, unknown fields are preserved, and it
  never fails the host command. `status` and `resume` commands carry decisions forward.
- **Composes:** in hook mode only, through mandatory `after_specify`/`after_plan`/`after_tasks`/
  `after_implement` hooks.
- **Hard rule 2 conflict:** its optional `companion-standard` preset uses `replaces:` on core commands
  (re-checked). Use hook mode only.
- **Health:** MIT, extension v0.23.0 (catalog 0.20.2), last commit 2026-10-01. About 835 of ~848
  commits are by one author, so the bus factor is effectively 1. The JSON schema is owned by the
  author's IDE extension.
- **Risks:** hooks are advisory on 1.0.13 (agent-interpreted). The file name must not collide with
  aisdlc's own state file.
- **Verdict:** design reference, and possibly schema-compatible co-existence. A deep-dive (schema
  stability, hook behaviour on non-dispatch integrations) is needed before any DEPEND.

### Intent Reconciliation (`intent`) — decision log
- **Format:** `specs/<feature>/decisions.md` with append-only `DEC-####` Proposal and Resolution
  records, and divergence classifications. Its README states: "Existing records are never edited,
  reordered, or deleted. An unattended run may append proposals but cannot infer human approval"
  (re-checked). This fits D-013 and D-023.
- **Health:** MIT, `speckit_version >=0.12.0`, v1.0.2, three commits, one maintainer.
- **Limit:** works through a wrapper around core `implement`; calling `/speckit.implement` directly
  bypasses it, as its README admits.
- **Verdict:** borrow the format (attribute in `NOTICE`); too small to depend on.

### DocGuard — docs reconciliation (optional checker)
- **What it does:** deterministic validators; `sync` refreshes code-truth sections between markers and
  keeps prose; audits AGENTS.md/CLAUDE.md; SARIF/JUnit output and CI recipes.
- **Health:** MIT, active (v0.43.0; catalog 0.41.6), several authors.
- **Limits:** needs Node and `npx` (re-checked in `extension.yml`) and imposes its own canonical doc
  layout.
- **Verdict:** document as an optional integration for teams wanting CI drift checks; not a bundle
  dependency and not the reconciler.

### `retrospective` (emi-dm) — retrospective (moderate contender)
- **What it does:** spec-adherence score, drift rules, root cause, constitution compliance, and a
  human gate before any `spec.md` change. Writes `FEATURE_DIR/retrospective.md` (durable, fits D-004
  and D-013).
- **Health:** MIT, `>=0.1.0`, three commits, last 2026-02-24, one author. **Installs on 1.0.13**
  (re-checked).
- **Verdict:** borrowing (with BMAD's "drop any finding you cannot tie to a source") is safer than
  depending on an unmaintained package that would sit inside our release gate.

## Notes per candidate (non-contenders)

- **verify:**
  - `speckit.converge` checks spec, plan, tasks and constitution against code, classifies gaps
    (missing / partial / contradicts / unrequested) and only appends tasks.
  - `analyze` is pre-implement and never reads code.
  - OpenSpec `/opsx:verify` contributes "never score a skipped check as passing".
- **review:**
  - Upstream ships none: the "code review skill" in the 1.0.x changelog (#4471) is a maintainer skill,
    not shipped to users.
  - `review` (ismaelJimenez) does not load spec or plan.
  - `staff-review` is one commit.
  - BMAD's triage (verify each claim at the cited line; `patch` / `decision_needed` / `defer`) is the
    best noise filter seen.
- **secure:**
  - Core `checklist` tests requirement quality, not code.
  - `security-review` (DyanGalih) is a broad OWASP diff toolkit with "only approved findings become
    tasks".
  - `sicario-core` replaces five core templates (hard rule 2; re-checked). Rejected.
- **remediate:**
  - The ecosystem pattern is findings → tasks appended to `tasks.md` → `implement` → re-check.
  - `fix-findings` loops `analyze` and edits code, a mismatch of purpose.
  - Define one task format modelled on converge's `per <source-ref> (<gap-type>)` tags.
- **guard:**
  - `architecture-guard` is a parallel 18-command lifecycle.
  - `arch-governance` patches `.specify/templates/{spec,plan}-template.md` in place (hard rule 2;
    re-checked).
  - `ci-guard`'s commands use a namespace that differs from its id, so it is expected to fail
    validation on 1.0.x (inferred from source, not tested).
  - Policy content such as architecture rules and framework rule sets belongs in organisation presets
    (D-007).
- **ship:**
  - Upstream `git` commits only; upstream `github` does only `taskstoissues`.
  - `ship` (arunt14) installs and asks before every destructive step, but has no PR-template discovery
    or `Closes #N`.
  - `pr-bridge` fails to install on 1.0.13 (command namespace mismatch).
  - BMAD's opt-in tracker adapters are a pattern for D-011.
- **deploy:**
  - Upstream's SDLC guide says deployment is plain CI "without an agent or a Spec Kit command".
  - The only deploy extension targets one cloud platform, and its preset replaces 8 core commands
    and 5 templates.
  - Product Forge's release-readiness checklist (rollout, rollback, monitoring) is the reusable idea.
  - Environment promotion is organisation-specific, and workflow slots are project-level (see
    `upstream-spec-kit.md`), so any deploy hook needs a setup step.
- **router:**
  - Upstream: "There is no automatic handoff between those processes" (SDD, `bug`, `assess`).
  - `gh-triage` depends on a third-party extension that reuses the id `bug`, which collides with
    upstream's bundled `bug`.
  - The router should send ideas → `assess`, bugs → upstream `bugfix`, small changes → aisdlc quick,
    and features → aisdlc feature, with a human confirming.
- **quick change flow:**
  - Upstream `lean` replaces 5 core commands (hard rule 2).
  - `tinyspec` is a one-file spec with no review.
  - The `openspec` port creates a second spec tree.
  - Decide in #9 whether the quick review checks the constitution.
- **retrospective:**
  - `retro` (arunt14) depends on its author's other folders.
  - Product Forge measures post-launch metrics through analytics MCPs.
  - Route each lesson to exactly one destination: constitution (D-014), agent context, ADR/docs,
    backlog via the D-011 tracker, or discard.
- **brownfield onboarding:**
  - Core `/speckit.constitution` already infers from repo context, and `docs/guides/existing-projects.md`
    warns against inventing standards.
  - `brownfield` (Quratulain-bilal) edits core templates in its bootstrap (re-checked; hard rule 2).
  - BrownKit is heavy and does not write the constitution.
  - Borrow BMAD's ledger with approval per write, and EF's observed-vs-guideline marking.
  - Run the scout as an explicit command or workflow step, not a `before_constitution` hook.
- **docs reconciliation:**
  - `adrkit` is Apache-2.0 and declares `>=0.13.0,<1.1.0` (re-checked), so it would block on Spec Kit
    1.1 — an organisation-preset option at most.
  - `archive` folds features into project memory without deleting specs, and leaves `agent-context`
    markers alone. Borrow its "bounded inputs" rule.
- **decision log and handoffs:**
  - Upstream records decisions in plan `research.md` and clarify sessions; link to them rather than
    copying.
  - **Naming clash:** upstream's command frontmatter already uses `handoffs:` (in clarify,
    constitution, plan, specify and tasks; re-checked) to mean "suggested next command". aisdlc should
    use a different term for session handoffs.
- **per-feature session state:**
  - Upstream state is per checkout (`.specify/feature.json`, gitignored) or per run
    (`.specify/workflows/runs/<run_id>/`). Nothing is per feature and committed.
  - aisdlc can mirror gate outcomes into `specs/<feature>/` from a `shell` step using
    `specify workflow status --json`, which stays within the contract.
  - A Markdown or JSONL append log is likely to merge more easily than a JSON document (untested).

## Cross-cutting findings

1. **Alias rule: docs and source disagree.**
   - `EXTENSION-API-REFERENCE.md` says aliases must use the extension namespace.
   - The 1.0.13 source does not enforce this. Its comment reads "no pattern enforcement on aliases — they
     are intentionally free-form to preserve community extension compatibility (e.g. 'speckit.verify'
     short aliases …)" (`src/specify_cli/extensions/__init__.py` lines 494–496, re-checked).
   - Installed extensions already register `/speckit-verify` and `/speckit-deploy`.
   - aisdlc should not rely on this, but must expect un-namespaced names taken by others. D-006's
     "impact" line and `upstream-spec-kit.md` should note it.
2. **A catalog listing does not mean it installs.** `pr-bridge` 1.0.0 and `verify-review-ship` 0.4.2
   fail validation on 1.0.13. This is more evidence that any DEPEND needs our own compatibility CI
   (hard rule 6, D-024). Pin dependencies to release tags; several catalogs lag their repos.
3. **Extended Flow has no LICENSE file.** MIT is declared only in its README badge and manifests. Before
   adapting EF material, the user may want to ask the author to add a LICENSE. Otherwise record the
   manifest author as copyright holder in `NOTICE`.
4. **Upstream does not vet extensions.** The catalog check is "form and completeness, not a security
   review" (`workflows/PUBLISHING.md`).
5. **Hooks are advisory.** Every candidate that relies on hooks inherits this, so aisdlc capabilities
   that must happen belong in workflow steps with D-023 artifact checks.

## Verification by the calling session

Claims re-checked against cloned sources or an install into a fresh 1.0.13 project before saving:
- **Install results:**
  - verify-review-ship fails on 1.0.13 with the script-name error.
  - threatspec, verify-tasks and the emi-dm retrospective extension install.
- **Manifests:**
  - threatspec preset uses `append` on four core commands, `>=1.0.0`.
  - verify-tasks `>=0.12.17`, alias `speckit.verify-tasks`.
  - adrkit Apache-2.0, `>=0.13.0,<1.1.0`.
  - intent `>=0.12.0`.
  - DocGuard requires node/npx.
- **Hard rule 2 conflicts:**
  - Companion preset `replaces:` core commands; sicario-core `replaces:` five templates.
  - arch-governance and brownfield edit core templates.
- **Other files:**
  - spec-gates verified against 0.12.4.
  - `intent` append-only wording.
  - upstream `handoffs:` frontmatter; the alias comment in the 1.0.13 source.
  - EF has no LICENSE file.

Not re-checked (single-run claims): activity and author counts, test-suite results, and claims about
Kiro and Tessl.

## Risks and unknowns

- **Kiro and Tessl:** assessed from search snippets only, because kiro.dev and docs.tessl.io are
  blocked by the egress proxy.
- **Opened only from catalog entries:** product-forge (partly), multi-model-review, red-team,
  orchestrator, maqa-ci, specassay.
- **Approximate counts:** maintainer and activity counts come from `git log` in clones; GitHub
  contributor data was not available.
- **Not tested:** whether `specs/tiny/` confuses upstream feature detection, and how hooks behave on
  integrations without CLI dispatch.

## Sources

**Upstream** — github/spec-kit @ v1.0.13 (https://github.com/github/spec-kit/tree/v1.0.13):
- Command templates: `templates/commands/{analyze,converge,checklist,constitution,plan,clarify}.md`
- Bundled extensions and presets: `extensions/{agent-context,assess,bug,git,github}/`,
  `presets/{lean,constitution-sync}/`
- Catalogs: `extensions/catalog.community.json`, `presets/catalog.community.json`,
  `workflows/catalog.community.json`, `bundles/catalog.community.json`
- Reference: `extensions/EXTENSION-API-REFERENCE.md`, `workflows/PUBLISHING.md`, `CHANGELOG.md`
- Guides: `docs/guides/{agentic-sdlc,existing-projects}.md`, `docs/reference/{core,workflows}.md`
- Source: `src/specify_cli/extensions/__init__.py`, `src/specify_cli/shared_infra.py`
- PyPI: https://pypi.org/pypi/specify-cli/json

**Community extensions and presets:**
- https://github.com/datastone-inc/spec-kit-verify-tasks
- https://github.com/cadugevaerd/spec-kit-verify-review-ship
- https://github.com/ismaelJimenez/spec-kit-verify
- https://github.com/ismaelJimenez/spec-kit-review
- https://github.com/arunt14/spec-kit-staff-review
- https://github.com/RbBtSn0w/spec-kit-extensions
- https://github.com/hupe1980/spec-kit-threatspec
- https://github.com/DyanGalih/security-review
- https://github.com/NaviaSamal/spec-kit-threatmodel
- https://github.com/dfirs1car1o/sicario-spec
- https://github.com/hindermath/spec-kit-preset-security-governance
- https://github.com/hindermath/spec-kit-preset-architecture-governance
- https://github.com/Quratulain-bilal/spec-kit-fix-findings
- https://github.com/dsrednicki/spec-kit-cleanup
- https://github.com/benizzio/spec-kit-coding-standards-drift-control
- https://github.com/schwichtgit/spec-gates
- https://github.com/DyanGalih/architecture-guard
- https://github.com/ashbrener/spec-kit-arch-governance
- https://github.com/Quratulain-bilal/spec-kit-ci-guard
- https://github.com/arunt14/spec-kit-ship
- https://github.com/Quratulain-bilal/spec-kit-pr-bridge-
- https://github.com/arrrrny/speckit-extensions
- https://github.com/pragya247/spec-kit-orchestrator
- https://github.com/Quratulain-bilal/spec-kit-tinyspec
- https://github.com/VaiYav/speckit-product-forge
- https://github.com/aaronrsun/spec-kit-openspec
- https://github.com/Azure-Samples/Spec2Cloud
- https://github.com/emi-dm/spec-kit-retrospective
- https://github.com/arunt14/spec-kit-retro
- https://github.com/stn1slv/spec-kit-archive
- https://github.com/Quratulain-bilal/spec-kit-brownfield
- https://github.com/MaksimShevtsov/BrownKit
- https://github.com/teeyo/spec-kit-time-machine
- https://github.com/philo-x/spec-kit-preset-codebase-memory-context
- https://github.com/raccioly/docguard
- https://github.com/mbeacom/adrkit
- https://github.com/ogil109/spec-kit-blueprint
- https://github.com/SuhaibAslam/spec-kit-reconcile
- https://github.com/alfredoperez/speckit-companion
- https://github.com/DyanGalih/spec-kit-memory-hub
- https://github.com/kotnisofiane-bit/dubsar-memory
- https://github.com/mvanhorn/speckit-utils

**Other tools:**
- https://github.com/markuswondrak/spec-kit-extended-flow (v0.18.0)
- https://github.com/Fission-AI/OpenSpec (v1.14.0)
- https://github.com/bmad-code-org/BMAD-METHOD (6.12–6.13)
- https://github.com/tesslio/spec-driven-development-tile
- https://github.com/anthropics/claude-code-security-review

**Secondary (search snippets only):**
- https://kiro.dev/docs/specs/
- https://kiro.dev/docs/hooks/
- https://docs.tessl.io/use/spec-driven-development-with-tessl
- https://tessl.io/blog/tessl-launches-spec-driven-framework-and-registry
