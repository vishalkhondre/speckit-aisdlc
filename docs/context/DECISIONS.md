# Decisions

Append-only. Never edit an accepted entry — supersede it with a new one that references it.
Status values: `accepted` (user decided), `proposed` (agent recommendation awaiting the user), `superseded`.

---

### D-001 — Project goal
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** Create `vishalkhondre/speckit-aisdlc`, combining the best of Spec-Kit Extended Flow and
an internal enterprise Spec Kit layer on top of GitHub Spec Kit. It must absorb new upstream Spec Kit
releases without breaking its own releases. (Scope refined by D-007.)

---

### D-002 — Packaging follows the Extended Flow model
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** Ship as standard Spec Kit packages installed on a stock `specify-cli`: an extension
(own namespaced commands), presets (compose onto core commands via `prepend`/`append`; new
templates), workflows (orchestration on upstream's workflow engine), and a bundle with its own
catalogs. No vendoring, no wrapper CLI.

**Why:** Composition lets upstream changes to core commands flow through untouched. A vendored
Spec Kit snapshot with full-copy command overrides needs a hand merge on every upstream release,
and upstream moves fast (1.0.13 as of 2026-10-01).

**Alternatives rejected:**
- Vendored Spec Kit + wrapper CLI + replacement overrides — upgrade cost and silent breakage via private APIs.

---

### D-003 — No offline / single-wheel install requirement
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** Offline install is not a requirement at the moment. speckit-aisdlc depends
on upstream `specify-cli` installed normally.

**Why:** Removes the main reason to vendor Spec Kit.

---

### D-004 — Specs are durable
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** `specs/<feature>/` is kept and committed. The finish step keeps all other EF
behavior (gather PR context, clean up other temporary run artifacts and the `.specify/feature.json`
pointer, commit, open PR) but never deletes the spec directory.

**Why:** Durable specs are needed for tracker and wiki linkage, retrospectives, decision logs, and
spec-to-code traceability.

**Alternatives rejected:**
- EF behavior (specs deleted after documentation reconciliation; docs layer is the only durable truth).

---

### D-005 — Commands are interactive
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** Commands run interactively by default (may ask the user questions).

**Why:** Keeps human-in-the-loop behavior such as clarification and branch-naming prompts.

**Impact:** EF's "Workflow Runtime" never-ask preamble must not be prepended globally — it is baked
into every invocation, including manual ones. How workflow runs get unattended behavior is open
(see STATUS.md).

---

### D-006 — Extension id and command namespace: `aisdlc`
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** The extension id is `aisdlc`. Every speckit-aisdlc command is `speckit.aisdlc.<command>`
in manifests, which agents with skills see as `/speckit-aisdlc-<command>`.

**Why:** In Spec Kit 1.0 the extension id is a mandatory command namespace, and aliases must stay
inside it. `aisdlc` is free in the upstream community catalog (checked 2026-10-01) and matches the
pattern `^[a-z0-9-]+$`.

**Alternatives rejected:**
- A company-specific name — not suitable for a general-purpose tool.
- `sdlc` — agent recommendation; user preferred `aisdlc`.

**Impact:** Short un-namespaced aliases (e.g. `speckit.verify`) are not possible in 1.0.

---

### D-007 — aisdlc is generic; organisation-specific content lives elsewhere
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** Build `aisdlc` as a generic, company-neutral Spec Kit add-on. Organisation-specific
content — compliance metadata sections, branch conventions, tracker and wiki defaults — is delivered
as separate presets in separate (private where needed) repos that install on top of aisdlc.

**Why:** Keeps this repo publishable and reusable, and keeps proprietary material out of it.

**Impact:** Clean-room rule (AGENTS.md hard rule 7): ideas may inform the design, but no code,
prompts or templates are copied from proprietary sources. aisdlc must expose extension points
(templates, config, hooks) that an organisation preset can fill.

---

### D-008 — Internal enterprise layer content may be reused, de-branded
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** The user confirmed the internal enterprise layer's material shared in the claude.ai
Project contains no IP concerns, so its prompts, templates and code may be adapted into aisdlc.
Everything adapted must be fully de-branded: no company name, abbreviation or product prefix in
templates, prompts, file or folder names, config keys, environment variables, variable names, or
examples.

**Supersedes:** the clean-room clause of D-007 (the rest of D-007 stands: aisdlc is generic and
organisation-specific defaults live in separate presets).

**Impact:** Adapted material gets neutral names (e.g. an `aisdlc`-scoped state folder and config
keys, `PROJ-123`-style tracker examples). The private analysis of that layer stays out of this repo.

---

### D-009 — MIT licence
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** aisdlc is released under the MIT licence.

**Why:** Matches Spec Kit and Extended Flow, keeps reuse and attribution simple (`NOTICE`).

---

### D-010 — Workflows own the approval gates; commands stay interactive
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** Human approval gates live in the workflows. Commands stay interactive when run by hand
(D-005). An unattended preamble is added only if the workflow engine can apply it per run rather than
to every invocation.

**Open:** whether the engine supports per-run behaviour — part of the upstream contract research.

---

### D-011 — Pluggable issue tracker
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** Issue → branch → PR automation goes through a tracker interface. GitHub issues are built
in; other trackers (e.g. Jira via MCP) are supplied by organisation presets.

---

### D-012 — Configurable branch naming
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** Branch names follow a configurable pattern (prefix, tracker key, slug), defaulting to
`feature/<key>-<slug>`.

---

### D-013 — Per-feature session state
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** Session state (gates, decision log, handoffs) is stored per feature under
`specs/<feature>/`, so parallel feature branches never collide.

---

### D-014 — Single constitution
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** One constitution, at upstream's location `.specify/memory/constitution.md`. Anything that
generates or proposes constitution content (e.g. brownfield onboarding) writes there, with human review.

---

### D-015 — Lifecycle commands decided in the capability map
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** Which lifecycle commands aisdlc adds beyond upstream (verify, review, secure, deploy,
retrospective, guard, router, ship, brownfield scout, remediate, …) is decided in
`docs/research/capability-map.md`, after prior-art review.

---

### D-016 — Specialist review agents and a published wiki
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** The repo carries four Claude Code subagents in `.claude/agents/`:
- `prior-art-researcher`, `software-architect`, `agile-delivery-consultant` — read-only reviewers
  (no write tools). Before a significant decision, the relevant reviewers assess the proposal and
  their reports are saved to `docs/reviews/`. They advise; the user decides.
- `documentation-writer` — maintains human-facing pages in `docs/wiki/` only.

`docs/wiki/` is published one way to the GitHub wiki by `.github/workflows/wiki-sync.yml` on every
push to `main`. The wiki is never edited directly.

**Why:** The spec-driven tooling space is crowded; independent, evidence-based review reduces rework.
One-way publishing keeps the repo the single source of truth.

**Alternatives rejected:**
- Agents writing directly to the wiki — drifts from the repo, two sources of truth.

**Limits:** All agents run on the same model and share its blind spots; key decisions still benefit
from human expert review. The SAFe-fluent consultant keeps aisdlc framework-neutral; SAFe-specific
behaviour belongs in organisation presets.

---

### D-017 — Work is tracked on GitHub Project #2; Claude Code is the single board writer
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** Work items are GitHub issues in this repo, tracked on the user's GitHub Project #2
(https://github.com/users/vishalkhondre/projects/2), with milestones = roadmap phases.
- **Claude Code** is the only agent that writes to issues and the board (via `gh`): creates issues,
  moves items to In progress, opens PRs that say `Closes #N`.
- **Claude chat** shapes the backlog by drafting issues (in the repo, or directly only when Claude Code
  is not active).
- **The user** sets priority and resolves `needs-decision` items.
- **GitHub's built-in project workflows** move closed issues and merged PRs to Done.

`STATUS.md` links to the board rather than repeating it; the wiki Roadmap reflects the milestones.

**Why:** Board state changes where the work happens (branches, PRs), `gh` access is reliable in Claude
Code, and a single writer prevents drift — the same reasoning as one repo editor at a time. Tracking our
own work as issue → branch → PR also exercises aisdlc's own flow (D-011, D-012).

**Alternatives rejected:**
- Both products editing the board — duplicate moves and drift from `STATUS.md`.
- Tracking only in `STATUS.md` — hard to scan; no link between work items and PRs.

---

### D-018 — Board automation runs in GitHub, not on a local machine
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** No board work depends on a local `gh` login. Claude Code (cloud) creates issues through its
GitHub connection; the project's built-in workflows add them to the board and move closed issues and
merged PRs to Done; setup needing labels, milestones or project access runs as a manually triggered
GitHub Action using the existing `WIKI_TOKEN` secret, extended by the user with the `project` scope (one classic PAT shared with the wiki publish workflow).

**Refines:** D-017 — the division of roles is unchanged; only the mechanism changes (D-017 assumed `gh`
in Claude Code, which has no valid login in the cloud container).

**Why:** The user does not want to run setup locally, and the built-in `GITHUB_TOKEN` cannot access
user-owned projects.

---

### D-019 — The repository is public; proprietary analysis stays private
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** `vishalkhondre/speckit-aisdlc` is a public repository. This is possible because aisdlc is
generic and de-branded (D-007, D-008). The analysis of the internal enterprise layer is kept only in the
private claude.ai Project, never in this repo.

**Background:** An earlier repository (`speckit-sdlc`) briefly published that analysis. It was deleted and
recreated under the current name so the material is not in any commit history.

**Impact:** Every commit must pass hard rule 7. Anything that cannot be written without naming an
organisation belongs in a private location, not here.

---

### D-020 — Git workflow: branch and pull request for every change
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** No agent pushes to `main`. Every change goes on a branch and is merged by the user through a
pull request.
- Claude chat branches: `chat/<topic>`.
- Issue work (normally Claude Code): `feature/<issue-number>-<slug>` (D-012), PR body `Closes #<n>`.
- Commits made by agents are authored as Claude (`noreply@anthropic.com`) with a `Co-Authored-By` trailer,
  so GitHub shows them as verified agent commits.

**Why:** Keeps `main` reviewed, lets two products work without overwriting each other (one editor at a
time still applies to shared files), and gives the board's "PR merged → Done" automation something to act on.

---

### D-021 — Roadmap phases are the milestones; compatibility CI before features
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** The roadmap has eight phases, each a GitHub milestone: 0 Discovery and decisions ·
1 Upstream contract · 2 Capability map · 3 Skeleton and compatibility CI · 4 MVP · 5 Breadth ·
6 Organisation preset · 7 First release. Phase 3 (a bundle that installs and is tested against supported
Spec Kit versions and the latest release) comes before any feature work.

**Why:** Upstream compatibility is the promise the project rests on (hard rule 6); building it first means
every later feature is tested against new Spec Kit releases from the start.

---

### D-022 — Project board conventions
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:**
- The project's **Auto-add** workflow is on, so every new issue in this repo lands on the board by itself.
  Closed issues and merged PRs move to Done through the built-in workflows.
- The board uses the project's existing status columns: Backlog → Ready → In progress → In review → Done.
  New items start in Backlog.
- Labels: `research`, `decision`, `needs-decision`, `build`, `docs`, `chore`.
- `scripts/board/bootstrap.sh` (run by the *Bootstrap project board* Action) is safe to re-run: it updates
  labels, skips existing milestones and issues, retries GitHub writes, and treats "already in this project"
  as success, because Auto-add usually adds an issue before the script does.

**Lesson recorded:** the first bootstrap run failed on that Auto-add race, not on a rate limit as first
assumed. Read the job log before diagnosing.

---

### D-023 — Unattended runs: gates in workflows, artifact checks after command steps
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude Code

**Decision:** aisdlc uses option 1 from `docs/research/upstream-spec-kit.md` § D-010:
- Human approval gates live in the workflows (`gate` steps; `verdict_input` where CI must pre-answer).
- Every `command` step in an aisdlc workflow is followed by a `shell` check that verifies the expected
  artifact exists (e.g. the file under `specs/<feature>/`), so a command that stopped to ask a question
  fails the run instead of passing silently.
- aisdlc's own commands ask only for information missing from their arguments.

**Refines:** D-010 — answers its open point. Spec Kit 1.0.13 has no per-run mechanism, so no unattended
preamble is added (D-005 stands).

**Why:** Stays entirely within the public contract. A non-interactive agent that asks a question exits 0,
so the artifact check is what makes gates trustworthy.

**Alternatives rejected:**
- Argument marker with a conditional preamble — leaks into `$ARGUMENTS`, not inherited by hooks, still
  text in every composed command.
- `prompt` steps — undocumented 300 s timeout, per-integration invocation syntax.
- Launcher environment / `SPECKIT_INTEGRATION_<KEY>_EXTRA_ARGS` — source-only and agent-specific.

**Review:** `docs/reviews/2026-10-01-upstream-contract-software-architect.md` (finding A1).

---

### D-024 — Supported Spec Kit range (provisional)
**Status:** accepted (provisional) · **Date:** 2026-10-01 · **Session:** Claude Code

**Decision:** aisdlc declares `speckit_version: ">=1.0.5,<2.0.0"`. The range is provisional and is
confirmed at Phase 3. Compatibility CI runs on the floor version, the latest release, and a schedule
against the latest release (hard rule 6).

**Why:** 1.0.5 adds workflow `slot` steps; 1.0.4 adds preset `requires.extensions`. Upstream tightens
validation in patch releases (#4191, #4477, #4558), so testing only on aisdlc changes is not enough.

**Review:** `docs/reviews/2026-10-01-upstream-contract-software-architect.md` (findings A6, A9).

---

### D-025 — Extended Flow material: ideas only, no verbatim copying
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** Extended Flow has no LICENSE file (MIT is declared only in its README and manifests). The user
chose not to contact the author and not to add a `NOTICE` entry. Therefore aisdlc **borrows Extended Flow's
ideas and designs only and never copies its text, prompts, templates or code verbatim**; aisdlc writes its
own versions.

**Why:** MIT's main condition is keeping the copyright notice with copied material. Ideas and designs are not
covered by the licence, so writing our own versions needs no notice.

**Review:** `docs/reviews/2026-10-01-prior-art-sweep-prior-art-researcher.md` (cross-cutting finding 3).

---

### D-026 — aisdlc defines no command aliases
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** aisdlc uses only full `speckit.aisdlc.<command>` names and defines no aliases. aisdlc never relies
on un-namespaced names such as `speckit.verify`.

**Why:** Spec Kit's docs require aliases to stay in the extension's namespace, but the 1.0.13 source does not
enforce it, and other extensions already register `/speckit-verify` and `/speckit-deploy`. Following the docs
keeps aisdlc safe if enforcement arrives and avoids collisions. Recorded in `upstream-spec-kit.md`.

**Refines:** D-006 (whose impact line assumed the documented rule is enforced).

---

### D-027 — "Briefs", not "handoffs"
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** The short note each phase leaves for the next is a **brief**. Per feature: `brief.md` (latest
brief), `decisions.md` (append-only decision log) and a small state file under `specs/<feature>/.aisdlc/`.
Exact file names are settled in the capability map.

**Why:** Upstream command frontmatter already uses `handoffs:` to mean "suggested next command".

---

### D-028 — Deploy is out of aisdlc's core
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** aisdlc's flows end at **ship**: a pull request ready to merge, with its evidence. aisdlc has no
deploy command or workflow. Release-readiness or deployment-record steps, if wanted, come from organisation
presets. Revisit after v0.1.

**Why:** Upstream's SDLC guide leaves deployment to plain CI; the sweep found nothing worth depending on;
environment promotion is organisation-specific; it was the least proven idea in either source project.

---

### D-029 — Capability map accepted
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** `docs/research/capability-map.md` (revision 2) is accepted as the plan for what aisdlc builds,
how, and in which phase, together with its Definition of Ready and Done, size rule, escalation path and
organisation-preset extension points. Its open questions are answered by D-030 to D-036.

**Review:** `docs/reviews/2026-10-01-capability-map-software-architect.md`,
`docs/reviews/2026-10-01-capability-map-agile-delivery-consultant.md`.

---

### D-030 — Docs reconciliation is the first item of phase 5
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** The MVP (phase 4) does not include `speckit.aisdlc.docs`. Instead, ship adds a short
"documentation possibly affected" note to the PR body. Docs reconciliation is the first phase 5 item.

**Why:** It is the heaviest new command and is not needed to get a verified PR out.

---

### D-031 — Review in phase 5; human PR review is the MVP's review
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** `speckit.aisdlc.review` arrives in phase 5. In the MVP, human PR review is part of the
feature flow's Definition of Done, ship refuses a non-PASS verify verdict, and security scanners can be
configured as verify checks from phase 4.

---

### D-032 — Tracker: GitHub and "none" first, pluggable later
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** Phase 4 supports `tracker: github` and `tracker: none` (`none` is also the fallback when `gh` is
missing). The pluggable tracker interface arrives in phase 5. The tracker key is stored generically in
`specs/<f>/.aisdlc/state.json` from phase 4, so the file format does not change later.

**Refines:** D-011.

---

### D-033 — Unit of work: one spec, one PR
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** By default one spec = one Feature-level backlog item = one branch = one PR; user stories map to
child items. Guidance is to keep specs small (one or two stories). `state.json` keeps a `stories` list so
per-story shipping can be added later without a format change.

---

### D-034 — Quick-scope review checks the constitution
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** `speckit.aisdlc.review` with the quick scope includes a constitution check (D-014).

---

### D-035 — Config format: flat YAML subset with a stdlib parser
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** aisdlc's config lives in `.specify/extensions/aisdlc/aisdlc-config.yml`, with per-machine
overrides in `local-config.yml` (already gitignored by upstream) and env `SPECKIT_AISDLC_*`. The files use a
documented flat key–value subset of YAML, parsed by aisdlc's own Python stdlib parser — no PyYAML, `yq` or
`jq`.

**Why:** Python's standard library has no YAML parser, and the `python3` that workflow steps call may not
have PyYAML. A flat subset keeps upstream's file-name conventions (and the automatic ignore of
`local-config.yml`) with no extra dependency.

---

### D-036 — Workflow testing in CI
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude chat

**Decision:** CI validates workflow files and runs every deterministic step (`shell` steps and aisdlc
scripts) against fixture projects on each change. Agent (`command`) steps are exercised in a manual or
scheduled job with a real agent CLI.

**Why:** Command steps need a dispatch-capable agent CLI, which normal CI runners do not have.

---

### D-037 — aisdlc preset priority 50
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude Code

**Decision:** aisdlc's preset is installed at priority 50 (`bundle/bundle.yml`, `scripts/dev/install-local.sh`).
Organisation presets and other presets at Spec Kit's default priority 10 therefore rank above it. Composition
still applies aisdlc's additions (prepend/append layers stack), so aisdlc's behaviour is kept while the
organisation's layer wins any conflict. A future second aisdlc preset uses priority 60.

**Why:** Presets resolve by `(priority, id)`, lower first. At the default 10, an organisation preset would rank
above or below aisdlc depending only on whether its id sorts before `aisdlc`. The capability map requires
organisation template sections to rank above aisdlc. Changing a bundle-owned priority after release needs
`--refresh`, so it was settled before the first release.

**Review:** `docs/reviews/2026-10-01-bundle-skeleton-software-architect.md` (finding A1).

---

### D-038 — Workflow names
**Status:** accepted · **Date:** 2026-10-01 · **Session:** Claude Code

**Decision:** aisdlc's workflows are named `aisdlc-feature`, `aisdlc-bugfix`, `aisdlc-quick` and
`aisdlc-onboard`. Each lives in `workflows/<name>/workflow.yml`.

**Why:** The `aisdlc-` prefix keeps them clear of upstream (`speckit`, `bugfix`, `assess`) and community
workflow ids. Settled before the first release (#20), because renaming a bundle-owned workflow id later means
users must remove and re-add it.

**Resolves:** #5.
