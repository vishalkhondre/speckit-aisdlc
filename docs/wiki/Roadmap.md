# Roadmap

| Phase | Output | Status |
|---|---|---|
| 0. Discovery and decisions | Research on Spec Kit and related projects; decisions D-001 to D-036 so far | Done |
| 1. Upstream contract | What Spec Kit 1.0 guarantees: manifests, composition, hooks, workflow engine (pinned at v1.0.13) | Done |
| 2. Capability map | Every candidate capability marked keep, adapt or drop, reviewed by the specialist agents | Done: map accepted (D-029) |
| 3. Skeleton and compatibility CI | An empty bundle that installs on supported Spec Kit versions and the latest release, configuration, setup, plus release checks | Next |
| 4. MVP | The feature flow end to end on GitHub: start, per-feature state, decisions and briefs, converge loop, verify (with optional security scanners), ship to PR | Planned |
| 5. Breadth | Docs reconciliation (first), review, remediation, bugfix and quick change flows, retrospective, onboarding, policy guard, pluggable tracker | Planned |
| 6. Organisation preset | A sample preset exercising every extension point (templates, defaults, tracker, Done criteria) | Planned |
| 7. First release | v0.1 | Planned |

Compatibility CI comes before features on purpose: it is the promise the project rests on, so every
feature after it is tested against new Spec Kit releases from the start.

The MVP does not include docs reconciliation. Instead, ship adds a "documentation possibly affected"
note to the pull request, and docs reconciliation is the first phase 5 item (D-030). Review also comes
in phase 5; in the MVP, human pull request review is part of Done (D-031). Deployment is out of scope
(D-028). See [Product overview](Product-Overview) for the flows.

## What is next

Phase 3: skeleton and compatibility CI. Six issues are drafted, in suggested build order:

1. **Bundle skeleton.** The extension, preset, a feature workflow stub and the bundle manifest, so
   aisdlc installs on a stock Spec Kit with almost no behaviour yet.
2. **Configuration loader.** Reads the project config, the per-machine override and environment
   variables, merges them and prints the result. A flat YAML subset with no extra dependencies (D-035).
3. **Setup command.** Writes the project config interactively and warns if `specs/` would be ignored
   by git. Organisation presets add their defaults here.
4. **Compatibility CI.** Installs the bundle on the oldest supported Spec Kit and the latest release,
   on every pull request and nightly, and checks that aisdlc's additions keep Spec Kit's own text intact
   (D-036).
5. **Release consistency checks.** One version across all packages, and a manual release workflow.
6. **Confirm the supported Spec Kit range.** Once CI runs, confirm or adjust the provisional range
   (D-024). This needs a decision from the user.

Workflow names are settled (D-038): `aisdlc-feature`, `aisdlc-bugfix`, `aisdlc-quick`, `aisdlc-onboard`.

Live work items: [project board](https://github.com/users/vishalkhondre/projects/2). Current detail: [`docs/context/STATUS.md`](https://github.com/vishalkhondre/speckit-aisdlc/blob/main/docs/context/STATUS.md).
