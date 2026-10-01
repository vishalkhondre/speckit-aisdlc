# Delivery review: capability map (#9)
Date: 2026-10-01 · Reviewer: agile-delivery-consultant

## Verdict
APPROVE WITH CHANGES. The feature-flow MVP is a sensible first increment. The map should still state each flow's Definition of Ready and Definition of Done, add stop gates where decisions actually happen (verify fails, the converge budget runs out, docs conflict), keep the tracker key and bugfix artifacts in committed per-feature files, and define the escalation path when a quick change or a bug grows.

## Checklist
| # | Check | Result | Evidence |
|---|---|---|---|
| 1 | Work-item fit | concern | One aisdlc feature is one `specs/<f>/`, one branch (capability #1) and one PR (#7). The upstream spec template holds several prioritised user stories (US1 to US3, each with an "Independent Test"). `tasks.md` groups tasks by `[US#]`. So a feature is closer to a backlog Feature than to a Story, but it ships as one PR. See D6. |
| 2 | Ready and done | concern | The map lists steps but no entry or exit criteria for any flow. Tests come in through verify (#5) and docs through #6. Review is not in the MVP's done (#8 is phase 5). See D1 and D2. |
| 3 | Gate placement | concern | The spec and plan gates (feature), the assessment gate (bugfix) and the plan gate (quick) are well placed. Three decision points have no gate or stop: verify FAIL, the converge loop running out of iterations (default 5), and docs conflicts that are "flagged for a human" (#6). No gate before ship is correct, because the PR merge is the human decision. See D3. |
| 4 | Traceability | concern | The chain FR → task (converge's `per <source-ref>`) → verification.md (results mapped to requirements) → PR is promising. Four gaps: the tracker key lives in the gitignored `.specify/feature.json`; bugfix artifacts live in `.specify/bugs/<slug>/`, outside `specs/`; the router's recommendation lives only "in chat"; and upstream tasks link to user stories, not to FR IDs. See D4. |
| 5 | Roles and handoffs | pass (minor concern) | One person can run every flow. The gates do not say who should approve, and nothing records who did. See D8. |
| 6 | Flow choice | concern | The router (#13) and the quick flow (#12) are phase 5, so in the MVP every change, however small, goes through the full feature flow. Quick FAIL "recommends the feature flow" but does not say what happens to the branch, the plan or the code already written. A bug that turns out to be a feature has no path at all. See D5. |
| 7 | Framework neutrality | pass (with gaps) | Nothing in the core assumes SAFe, Scrum or a particular tracker. The "Delivery-framework mapping" row is too vague to build against. A SAFe preset also needs a generic parent link, generic tags (for PI and iteration) and organisation-wide config defaults. See D7. |
| 8 | Overhead | pass (minor concern) | The feature flow adds about 4 commands, 2 gates and 5 per-feature files to plain Spec Kit. Most of them pay for themselves; `brief.md` and `docs-report.md` are the weakest. See D9. |

## Findings

### D1: Review in phase 4 or 5 (open question 1) (severity: medium)
**What.** The MVP PR carries verification evidence but no structured review. That is acceptable only if the MVP's Definition of Done says plainly that human PR review is the review step. As written, the map is silent.

**Why it matters.** Built-in quality means quality is built in throughout, not inspected at the end ("Inspection is too late", SAFe Built-In Quality). DORA's research favours lightweight peer review captured in the team's development platform over heavyweight approval steps. The PR review already provides that. What the MVP lacks is *security* checking: under #10, security is only a review area, so the MVP has none.

**Suggested change.** Keep the multi-area review (#8) in phase 5, so the end-to-end flow ships sooner. Phase 4 then needs three things:
- **DoD wording:** "human PR review approved" is part of the feature flow's done.
- **Ship gating on verify:** ship puts the verify verdict and a requirement-coverage summary in the PR body. It refuses, or loudly flags, any verdict that is not PASS.
- **Security through configured checks:** verify's configured check list (#17) has a documented slot for a dependency scan, secret scan or SAST command. Security checking then exists in the MVP without the review command.

This changes the price in open question 1 from "no review" to "no AI pre-review".

### D2: No Definition of Ready / Done per flow (severity: high)
**What.** Each flow is described as a list of steps, with no entry or exit criteria.

**Why it matters.** The Scrum Guide treats a backlog item as "ready" when it "can be Done by the Scrum Team within one Sprint". It defines Done as "a formal description of the state of the Increment when it meets the quality measures required". Teams and organisation presets need something concrete to extend. D-023's artifact checks are already half of a mechanical DoD.

**Suggested change.** Add a DoR/DoD table to the map, roughly:

| Flow | Ready (to start) | Done (to ship) |
|---|---|---|
| Feature | Tracker item exists; problem statement; the router (or a human) chose this flow | Spec and plan approved; all tasks closed; converge clean; verification PASS with no skipped checks counted as passing; docs reconciled with no open conflicts; PR links the tracker item and the spec; human PR review |
| Bugfix | Reproducible report or tracker item | Assessment approved; regression test added and passing; "verified" (#11); PR |
| Quick | Fits the size rule; no new requirement | Quick-review PASS (constitution included); doc check; PR |

Then add an extension-point row: "DoD additions: guard policy (#16) and verify check commands", so an organisation can tighten done without forking.

### D3: Missing gates at real decision points (severity: medium)
**What.** The gates after specify and plan are right: those are the product and design decisions. Three other decision points have no defined behaviour:
1. **Verify FAIL in the MVP.** Remediation (#9) is phase 5, so the map does not say whether the flow loops, stops or ships anyway.
2. **Converge loop exhausted** after the default 5 iterations.
3. **Docs conflicts.** #6 says conflicts are "flagged for a human" but never resolved by the agent, yet no gate sits after docs.

**Why it matters.** Under D-023, a decision with no gate becomes either a silent pass or an unexplained failure. Both erode trust in the flow.

**Suggested change.**
- **Stops, not approvals.** Make verify FAIL and loop exhaustion stop steps with a reason written to `state.json` and `brief.md`, not approval gates. A human decides what happens next.
- **Docs gate only when needed.** Add a gate after docs that fires only when `docs-report.md` lists unresolved conflicts.
- **No pre-ship gate.** Do not add a gate before ship; the PR merge is that gate.
- **Consistency.** Product-Overview shows a Clarify step before spec approval and the map's feature row does not. Make them agree.

### D4: Traceability does not yet survive people and sessions (severity: high)
**What.** The forward chain is good: FR-### → tasks appended with `per <source-ref>` → verification.md maps results to requirements → PR closes the issue. Five gaps remain:
- **Tracker key not committed.** It is written to `.specify/feature.json` (#1), which upstream gitignores and keeps per checkout. A second person, or a fresh clone, loses the link between the spec and the tracker item. `state.json` (#3) mirrors gate outcomes but is not said to hold the key.
- **Bugfix artifacts outside `specs/`.** The bugfix flow writes to `.specify/bugs/<slug>/` (upstream `bug`). That sits outside `specs/`, so D-004 durability and D-013 per-feature state do not clearly apply. It also contradicts "Every flow keeps its specs, writes per-feature decisions and briefs."
- **Router choice not recorded.** The recommendation is "in chat" (#13), so the reason a flow was chosen is lost.
- **Tasks map to stories, not requirements.** Upstream tasks are tagged by story (`[US1]`), not by requirement. Requirement-level tracing therefore depends on verify's mapping alone.
- **No backward link from code.** No rule ties commits or the PR body to task IDs or the spec path.

**Why it matters.** Trace-back (PR → spec → decision) is what reviewers and auditors actually do, and per-checkout state breaks the moment work changes hands.

**Suggested change.**
- **Committed tracker key.** Store the tracker key, the flow type and the spec path in a committed file (`state.json` or spec frontmatter).
- **Bugfix pointer.** Give the bugfix flow a per-bug committed home or pointer: either mirror into `specs/<f>/` or record the `.specify/bugs/<slug>/` path in `state.json`. Also confirm that directory is committed.
- **Record routing.** Have the router append a `DEC-####` entry when a human confirms a route.
- **PR body.** Ship writes the spec path, the verification verdict and the requirement coverage into the PR body.
- **Optional commit trailer.** A task ID in commit messages, as a config option rather than a rule.
- **Committed specs check.** Start or ship should check that `specs/` is not gitignored. Upstream's own guide notes generated `specs/` artifacts are "normally gitignored", which would silently defeat D-004.

### D5: Flow choice and escalation (severity: medium)
**What.**
1. Until phase 5, the MVP has one flow, so trivial changes face the full ceremony and teams will bypass aisdlc.
2. When quick-review FAILs, it recommends the feature flow, but the handover is undefined.
3. Nothing covers a bug whose assessment shows a missing capability, or a feature that turns out to be a one-liner.

**Why it matters.** A flow that is too heavy gets skipped, and work restarted from scratch loses its context. Upstream's contribution guide already lets small fixes use the normal issue and PR process.

**Suggested change.**
- **MVP guidance.** State that small fixes use a plain branch and PR until the quick flow ships.
- **Escalation:**
  - Keep the branch.
  - Record a `DEC-####` entry for the escalation.
  - Pass the quick plan, or the bug assessment, as input to `specify`.
  - Keep any code already written for converge to assess.
- **Size rule.** Give the router an explicit, configurable size rule (for example: new requirement, more than N files, schema or API change → feature). This is the BMAD idea the sweep already recommends borrowing. Bugfix gets the same escalation from its assessment gate.

### D6: Unit of work and batch size (severity: medium)
**What.** A spec holds several independently testable user stories, but the map ships one PR per feature.

**Why it matters.** SAFe describes a story as functionality a team "can finish in a few days or less". DORA associates small batches with better delivery performance. One PR per multi-story spec is a large batch, and it maps awkwardly to trackers whose backlog item is the story.

**Suggested change.** Document the mapping: a spec ↔ a Feature-level item, and user stories ↔ child items. Either size a spec to one story, or let ship run per completed user story with the spec staying open until the last one. This could be a phase-5 option, but the decision should be recorded now, because it shapes `state.json`.

### D7: SAFe can be expressed, but the extension points need four generic hooks (severity: medium)
**What.** Tracker composition of start and ship, template `append`, project-level slots and constitution content cover most of what a SAFe organisation needs. Four things are missing or vague:
- **Parent link.** A generic, framework-free `parent` reference captured at start and stored in `state.json`, so a preset can link Story → Feature → Epic.
- **Tags.** A generic `tags`/metadata map in `state.json`, plus a spec-template section, so a preset can carry PI and iteration labels without aisdlc knowing what a PI is.
- **Organisation-wide defaults.** The map already proposes letting aisdlc's config loader read a defaults template that a preset supplies by name. Without it, every repo must set branch patterns and checks by hand, which is high friction for organisation-wide rollout. Decide this in phase 3, not leave it optional.
- **Concrete mapping row.** "Delivery-framework mapping" should name the concrete points above.

**Why it matters.** These keep aisdlc neutral while making a SAFe, Scrum or Kanban preset possible without forking. Slots being project-level only (D-024) is acceptable, but the setup step (`overlay add`) should be part of the organisation-preset documentation.

### D8: Gate ownership and approval record (severity: low)
**What.** The gates do not name a role, and the state file does not record who approved or when.

**Suggested change.** Make each gate's message configurable, for example "product approval" for the spec and "technical approval" for the plan. Record the approver and timestamp in `state.json`/`decisions.md` as part of #3, for audit and separation of duties. Keep this neutral: no role names in the core.

### D9: Overhead versus plain Spec Kit (severity: low)
**What.** Plain Spec Kit's feature path is about 6 commands: specify, clarify, plan, tasks, analyze, implement/converge. The aisdlc feature flow adds:
- **Commands:** about 4 (start, verify, docs, ship).
- **Gates:** 2.
- **Files:** 5 (`decisions.md`, `brief.md`, `state.json`, `verification.md`, `docs-report.md`).

| Addition | Pays for itself? |
|---|---|
| start, ship | Yes. Branch, tracker link and PR are work teams do anyway; aisdlc automates it. |
| verify / `verification.md` | Yes. It is the evidence for done. |
| `decisions.md` | Yes. It is what makes trace-back possible. |
| `state.json` | Yes. It makes resuming and handover possible. |
| `brief.md` | Partly. It is overwritten per phase and duplicates the latest state; consider making it a section of `state.json` or of the PR body. |
| `docs-report.md` | Weak. It could become a PR-body section unless there are conflicts. |

**Suggested change.** Merge or trim the two weakest files to reduce files per feature. Report the step count in the Product Overview so teams can judge the cost.

### Remaining open questions
- **Q2 (tracker interface timing):** phase 5 is fine, provided phase 4 already stores the tracker key generically (D4), so no file format changes later.
- **Q3 (quick-review checks the constitution):** agree, yes.
- **Q4 (deep-dives before any DEPEND):** agree they are not needed for the MVP.

## Sources
- Scrum Guide 2020, "Product Backlog" (readiness) and "Commitment: Definition of Done": https://scrumguides.org/scrum-guide.html
- SAFe, Built-In Quality: https://framework.scaledagile.com/built-in-quality/
- SAFe, Story: https://framework.scaledagile.com/story
- DORA, Streamlining change approval (peer review in the development platform over heavyweight approval): https://dora.dev/capabilities/streamlining-change-approval/
- github/spec-kit v1.0.13:
  - `templates/spec-template.md` (user stories with priorities, independent tests, FR/SC IDs)
  - `templates/tasks-template.md` (`[US#]` task tags)
  - `extensions/bug/README.md` (`.specify/bugs/<slug>/`)
  - `docs/guides/agentic-sdlc.md` ("Generated `specs/` artifacts are normally gitignored"; small fixes use the normal PR process)
- Repo: `docs/research/capability-map.md`, `docs/context/DECISIONS.md` (D-004, D-011, D-013, D-014, D-023, D-024, D-028), `docs/context/STATUS.md`, `docs/wiki/Product-Overview.md`, `docs/reviews/2026-10-01-prior-art-sweep-prior-art-researcher.md`, `docs/research/upstream-spec-kit.md`
