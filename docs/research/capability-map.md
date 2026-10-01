# Capability map

**Status:** accepted (revision 2) — D-029, decided in #10 on 2026-10-01; open questions answered by D-030 to D-036.
**Issue:** #9 · **Date:** 2026-10-01 · **Author:** Claude chat
**Inputs:** `docs/research/upstream-spec-kit.md` (contract pinned at Spec Kit 1.0.13),
`docs/reviews/2026-10-01-prior-art-sweep-prior-art-researcher.md` (14 candidates), decisions D-001 to D-028.
**Reviews of revision 1** (both APPROVE WITH CHANGES; all findings addressed below, see the last section):
`docs/reviews/2026-10-01-capability-map-software-architect.md` (A1–A11),
`docs/reviews/2026-10-01-capability-map-agile-delivery-consultant.md` (D1–D9).

For every candidate capability, this map says: keep, adapt or drop; how it is built on Spec Kit's public
contract; which phase delivers it; what an organisation preset can change; and its de-branded name.

## Design rules

1. **Mandatory behaviour lives in workflow steps**, each followed by a deterministic `shell` check (D-023).
   Hooks and preset-composed text are read and followed by the agent, so they are **best-effort**: fine for
   manual runs, never the only guarantee.
2. **Compose, never replace** core commands (hard rule 2), and never compose a core command in a way that
   contradicts its own rules (e.g. `converge` may only append to `tasks.md`).
3. **Results flow through files.** Command steps return only an exit code, so every step that matters
   writes a file a `shell` step can check. Read-only commands (`analyze`, `clarify` questions) stay manual.
4. **Deterministic work is done by scripts, judgement by the agent.** Running tests, hashing files and
   recording gate outcomes are `shell` steps; mapping results to requirements is a command.
5. **Reuse upstream first**: `converge`, the `bug` extension, `assess`, `constitution`.
6. **Generic, de-branded, no aliases** (D-007, D-008, D-026); **ideas, not copies** (D-025).

## The product at a glance

| Flow | Steps | Phase |
|---|---|---|
| **Feature** | start → specify → *spec gate* → plan → *plan gate* → tasks → implement → converge loop → verify → ship | 4 (MVP) |
| **Bugfix** | start → upstream `bug.assess` → *assessment gate* → `bug.fix` → `bug.test` → verified check → ship | 5 |
| **Quick change** | start → quick-plan → *plan gate* → quick-implement → review (quick scope) → ship | 5 |
| **Onboarding** | scout → proposal → *team review* → upstream `/speckit.constitution` | 5 |

- **Manual commands around the flows:** `clarify` (run at the spec gate if the spec has open questions,
  then resume) and `analyze` (read-only; useful before the plan gate). Neither runs unattended, because
  neither writes a checkable file.
- **Every flow** records flow type, tracker key, gate outcomes and decisions in committed per-feature
  files, keeps its specs (D-004) and ends at ship (D-028).
- **Until the quick flow ships (phase 5),** small fixes use a plain branch and PR; the feature flow is for
  features.

## Definition of Ready and Done

Mechanical checks (D-023) enforce the bold items; the rest is team practice that aisdlc records.

| Flow | Ready to start | Done (ready to merge) |
|---|---|---|
| Feature | A tracker item (or none, if `tracker: none`); a problem statement; flow type confirmed at start | **Spec and plan approved at gates**; **all tasks closed and converge clean**; **verification PASS** (no skipped check counted as passing); PR links tracker item and spec; **human PR review approved** |
| Bugfix | A reproducible report or tracker item | **Assessment approved**; **regression test added and passing**; **bug test result `verified`**; PR; human PR review |
| Quick | Fits the size rule (below); no new requirement | **Plan approved**; **review PASS** (constitution included); PR; human PR review |

**Organisations tighten Done** through verify's configured checks and guard policy (extension points below),
without forking aisdlc.

**Size rule for choosing a flow** (configurable): a new requirement, a schema or public API change, or more
than *N* files (default 5) → feature flow; otherwise quick. A defect in existing behaviour → bugfix. An idea
not yet worth building → upstream `assess`.

**Escalation** (quick → feature, or bug → feature): keep the branch; append a `DEC-####` entry recording why;
pass the quick plan or bug assessment to `specify` as input; leave any code already written for `converge`
to assess.

## Capability table

| # | Capability | Verdict | Mechanism | Phase | Output |
|---|---|---|---|---|---|
| 1 | **Setup** | keep | Command `speckit.aisdlc.setup`: writes the project config interactively, adds the local-override ignore line, checks that `specs/` is not gitignored. **Organisation defaults:** an organisation preset `append`s its defaults to this command | 3 | config file |
| 2 | **Configuration** | keep | `.specify/extensions/aisdlc/aisdlc-config.yml` + `local-config.yml` (already gitignored by upstream) + env `SPECKIT_AISDLC_*`, merged by `aisdlc-config.py`. Format: a documented flat key–value YAML subset parsed by a small stdlib parser (no PyYAML, no `yq`) — see open question 6 | 3 | merged config (JSON on stdout) |
| 3 | **Compatibility CI** | keep | GitHub Actions on floor `1.0.5`, latest and a nightly schedule: install the bundle; assert composed commands contain the upstream body; naming guardrail (`aisdlc-` prefix); `specify integration upgrade` test; **org-style preset composing an aisdlc command survives `extension update`**; deterministic workflow steps run against fixtures (agent steps stubbed — open question 7) | 3 | CI status |
| 4 | **Start** | keep | Command `speckit.aisdlc.start` (manual) and `shell` step `aisdlc-start.py` (workflows): computes the feature directory and branch from the configurable pattern (D-012), creates the branch, links the tracker item, records flow type + reason as a `DEC-####` entry. The directory is passed to `specify` explicitly; `.specify/feature.json` stays upstream's | 4 | branch, `specs/<f>/.aisdlc/state.json` |
| 5 | **Per-feature state** | keep | `specs/<f>/.aisdlc/state.json` (committed, small, written by start): flow type, spec path, tracker key, optional `parent` and `tags` (generic, for organisation presets), bug-report path for bugfix. `specs/<f>/.aisdlc/events.jsonl` (append-only): one line per gate or check, written by a `shell` step from workflow expressions (`steps.<gate>.output.choice`, `context.run_id`), with timestamp and the git user as approver | 4 | state + event log |
| 6 | **Decisions and briefs** | keep | `specs/<f>/decisions.md` (append-only `DEC-####`) and `specs/<f>/brief.md` (latest brief, D-027). aisdlc's own commands write them natively. Preset `aisdlc` **appends** a short best-effort section to core `specify`, `plan`, `tasks`, `implement` — **not** to `converge`. In workflows a `shell` check confirms `brief.md` was updated after each of those steps | 4 | decision log, brief |
| 7 | **Converge loop** | keep (reuse core) | `do-while` around core `converge` → `shell` check `aisdlc-converge-check.py` (hash of `tasks.md` before/after, JSON output) → `implement` if tasks were appended. Bounded (default 5). **After the loop, a check stops the run if work remains** (engine continues silently on exhaustion). No gates inside the loop | 4 | appended tasks |
| 8 | **Verify** | adapt (DEPEND on core converge) | `shell` step `aisdlc-checks.py` runs the configured checks (tests, lint, and optional security scans) and writes JSON; command `speckit.aisdlc.verify` maps results to requirements and writes the verdict; **a `shell` check stops the run unless the verdict is PASS** (a skipped check never passes) | 4 | `specs/<f>/verification.md` |
| 9 | **Ship** | keep | Command `speckit.aisdlc.ship`: refuses a non-PASS verdict (an explicit override is recorded as `DEC-####`); PR body carries spec path, verdict, requirement coverage, decision summary and (until phase 5) a "documentation possibly affected" note (D-030); PR-template discovery; commit prefix by flow type; base branch from config; tracker via one config key `tracker: github` or `tracker: none` (`none` prints the PR command; also the fallback when `gh` is missing); **specs kept** (D-004) | 4 | commit + PR |
| 10 | **Docs reconciliation** | keep | Command `speckit.aisdlc.docs`: three documentation layers, observed vs guideline content, conflicts flagged for a human and never auto-resolved, bounded inputs. Report goes into the PR body; a separate report file only when there are conflicts, followed by a gate that fires only then. | 5 (D-030) | updated docs |
| 11 | **Review** (incl. security) | keep | Command `speckit.aisdlc.review` with scopes `full` and `quick`: read-only reviewers per area (correctness, security, maintainability; quick scope adds a constitution check); each finding verified at its cited line and triaged `fix` / `needs-decision` / `defer` | 5 | `specs/<f>/review.md` |
| 12 | **Remediate** | adapt | No command: `fix` findings become tasks appended in converge's `per <source-ref> (<gap-type>)` style, then the converge loop runs again, bounded | 5 | appended tasks |
| 13 | **Secure** | adapt | A review area (#11) plus security scanners in verify's configured checks (#8, available from phase 4). `threatspec` documented as an optional companion, not a bundle dependency | 4 (scanners), 5 (review area) | findings |
| 14 | **Bugfix flow** | adapt | aisdlc workflow around upstream `bug` commands: start (state records the `.specify/bugs/<slug>/` path, which upstream does not gitignore), artifact checks, `verified` check, ship. Upstream's `bugfix` workflow stays usable on its own | 5 | bug reports + PR |
| 15 | **Quick change flow** | keep | Workflow + commands `quick-plan`, `quick-implement`; review with quick scope. Writes a minimal `spec.md` (instruction + acceptance line) so upstream tools that require a spec still work | 5 | `specs/<f>/spec.md`, `plan.md` |
| 16 | **Flow choice** | adapt (was "router") | No separate command: `start` applies the size rule, asks the human to confirm, and records the choice as `DEC-####`. Guidance page in the wiki | 4 (feature only), 5 (all flows) | decision entry |
| 17 | **Retrospective** | keep | Command `speckit.aisdlc.retro`: evidence-sourced lessons, each routed to exactly one destination (constitution proposal, agent context, ADR/docs, tracker backlog, discard); proposals only | 5 | `specs/<f>/retrospective.md` |
| 18 | **Brownfield onboarding** | keep | Command `speckit.aisdlc.scout`: reviewable proposal with observed-vs-guideline marking; human approves; upstream `/speckit.constitution` writes the constitution (D-014). Explicit command, not a hook | 5 | `docs/aisdlc/onboarding-proposal.md` |
| 19 | **Guard** (policy checks) | adapt | The D-023 artifact checks are the first guard (phase 4); a policy file supplied by organisation presets and the same check script callable from git hooks or CI (phase 5) | 4, 5 | check results |
| 20 | **Sub-agent delegation**, **per-step model routing** | later | Ideas from EF; after v0.1 | later | — |
| 21 | **Deploy** | **drop** | Out of core (D-028) | — | — |

**Also dropped by earlier decisions:** a global never-ask preamble (D-005, D-023); deleting specs (D-004);
branching through the `git` extension's hook; short aliases (D-026). **Removed in this revision:** `analyze`
and `clarify` as unattended workflow steps (they write nothing checkable); a separate `route` command; a
separate `quick-review` command; appending to `converge`; reading `.specify/feature.json` as aisdlc's source
of truth.

## Unit of work

- **One spec = one backlog Feature-level item = one branch = one PR** by default. User stories inside the
  spec map to child items in the tracker.
- **Guidance:** keep specs small (one or two user stories) so PRs stay small. `state.json` keeps a `stories`
  list so a later option can ship per completed story without changing the file format.

## Phase plan

| Phase | Delivers (capability #) |
|---|---|
| **3 · Skeleton and compatibility CI** | 1 setup, 2 config, 3 compatibility CI; an empty bundle (extension + preset + feature workflow stub) installing on floor and latest |
| **4 · MVP** | 4 start, 5 state, 6 decisions and briefs, 7 converge loop, 8 verify (incl. security scanners), 9 ship, 16 flow choice (feature only), 19 artifact checks → **feature flow end to end on GitHub** |
| **5 · Breadth** | 10 docs (first), 11 review, 12 remediate, 13 secure review area, 14 bugfix flow, 15 quick flow, 16 all flows, 17 retrospective, 18 onboarding, 19 policy guard, pluggable tracker interface |
| **6 · Organisation preset** | A sample preset exercising every extension point below, including the setup-defaults path |

## Organisation-preset extension points

| Extension point | How (within the public contract) | Example use |
|---|---|---|
| Template sections | Preset `append`/`wrap` on core templates, ranked above aisdlc | Compliance metadata, non-functional requirement slots |
| Organisation defaults | Preset `append`s to `speckit.aisdlc.setup` with its defaults (branch pattern, base branch, checks, tracker) | `Feature/<KEY>-<slug>`, `develop` as base |
| Done criteria | Verify's configured checks; guard policy file | Required scanners, coverage threshold |
| Issue tracker | Preset composes the **tracker section** of `start` and `ship` (append), with `tracker` set accordingly; phase 5 adds a pluggable interface | Jira via MCP |
| Hierarchy and tags | Generic `parent` and `tags` in `state.json`, captured at start; a spec-template section via the template extension point | Epic → Feature → Story links; PI or iteration labels |
| Review areas | Preset composes `speckit.aisdlc.review` (phase 5) | Framework or architecture rules |
| Constitution | The organisation runs upstream `/speckit.constitution` with its principles | Engineering standards |
| Extra workflow steps | **Project-level only:** aisdlc workflows expose `slot` steps (e.g. `org-checks`, `pre-ship`) filled with `specify workflow overlay add` (≥ 1.0.5, D-024). A filled slot has no artifact check unless the overlay adds one. For packaged behaviour, compose `speckit.aisdlc.ship` instead | Release-readiness record |

Composition onto aisdlc commands is materialised at install time; CI (#3) checks that it survives an
`extension update`, and the organisation-preset guide will say what to re-run if it does not.

## De-branded names

- **Commands:** `speckit.aisdlc.setup`, `start`, `verify`, `ship`, `docs`, `review`, `retro`, `scout`,
  `quick-plan`, `quick-implement` (skill agents see `/speckit-aisdlc-<name>`).
- **Per-feature files:** `specs/<f>/decisions.md`, `brief.md`, `verification.md`, `review.md`,
  `retrospective.md`, `.aisdlc/state.json`, `.aisdlc/events.jsonl`.
- **Config and scripts:** `.specify/extensions/aisdlc/aisdlc-config.yml`, `local-config.yml`,
  env `SPECKIT_AISDLC_*`; scripts `aisdlc-*.py` (Python 3 stdlib); templates `aisdlc-*`;
  decision IDs in user projects `DEC-####`.
- **Workflows:** `aisdlc-feature`, `aisdlc-bugfix`, `aisdlc-quick`, `aisdlc-onboard` (D-038).

## Decisions on the open questions (#10)

| # | Question | Decision |
|---|---|---|
| 1 | Docs reconciliation phase | Phase 5, first item; the MVP's PR notes "documentation possibly affected" (D-030) |
| 2 | Review timing | Phase 5; human PR review is in the MVP's Done; ship refuses non-PASS; scanners in verify from phase 4 (D-031) |
| 3 | Tracker | GitHub and `none` in phase 4, pluggable in phase 5, key stored generically from phase 4 (D-032) |
| 4 | Unit of work | One spec = one PR; small specs; per-story shipping later (D-033) |
| 5 | Quick review and the constitution | Yes (D-034) |
| 6 | Config format | Flat YAML subset, stdlib parser (D-035) |
| 7 | Workflow testing in CI | Deterministic steps on fixtures in CI; agent steps in a manual or scheduled job (D-036) |
| 8 | Workflow names | Settled by D-038: `aisdlc-feature`, `aisdlc-bugfix`, `aisdlc-quick`, `aisdlc-onboard` |

## How the reviews were addressed

| Finding | Change |
|---|---|
| A1 converge loop end / exhaustion | #7: hash-based check with JSON output drives the loop; post-loop stop |
| A2 `analyze` unverifiable | Removed from workflows; manual command |
| A3 appending to `converge` | Not composed; other compositions labelled best-effort and checked in workflows (#6) |
| A4 config loader | #2: flat YAML subset + stdlib parser; local file named `local-config.yml`; organisation defaults via `setup` composition instead of a template resolver |
| A5 gate choices | #5: `events.jsonl` written from workflow expressions |
| A6 tracker composition | #9: `tracker: github` or `none`; presets compose the tracker section; CI tests survival across `extension update` |
| A7 feature directory | #4: start computes and passes the directory; `.specify/feature.json` not relied on |
| A8 MVP completeness | Verdict check (#8), deterministic checks script, CI approach (open question 7), docs moved to open question 1, `analyze` removed |
| A9 simplicity | `quick-review` merged into `review` scopes; `route` replaced by `start` + wiki guidance |
| A10 slots | Caveat and the packaged alternative added to the extension-point table |
| A11 bugfix/quick files | #14 records the bug-report path; #15 writes a minimal `spec.md` |
| D1 review timing | Open question 2; DoD includes human PR review; ship refuses non-PASS; scanners in verify from phase 4 |
| D2 DoR/DoD | New section |
| D3 missing stops | Post-loop stop, verify-verdict stop, docs gate only on conflicts; Clarify moved to a manual step at the spec gate |
| D4 traceability | Committed `state.json` (tracker key, flow, spec path, bug path); flow choice recorded; PR body contents; `specs/` gitignore check in setup |
| D5 flow choice and escalation | Size rule, escalation steps, MVP guidance for small fixes |
| D6 unit of work | New section; open question 4 |
| D7 SAFe expressibility | Generic `parent` and `tags`; organisation defaults via setup; concrete extension-point rows |
| D8 approval record | Approver (git user) and timestamp in `events.jsonl`; gate messages stay neutral |
| D9 overhead | `docs-report.md` folded into the PR body unless there are conflicts; `brief.md` kept (D-027) |
