# Roadmap

| Phase | Output | Status |
|---|---|---|
| 0. Discovery and decisions | Research on Spec Kit and related projects; decisions D-001 to D-022 | Done |
| 1. Upstream contract | What Spec Kit 1.0 guarantees: manifests, composition, hooks, workflow engine (pinned at v1.0.13) | Done, pull request awaiting merge |
| 2. Capability map | Every candidate capability marked keep, adapt or drop, reviewed by the specialist agents | Next |
| 3. Skeleton and compatibility CI | An empty bundle that installs on supported Spec Kit versions and the latest release, plus release checks | Planned |
| 4. MVP | Feature workflow with durable specs, per-feature session state, docs reconciliation, finish to PR | Planned |
| 5. Breadth | Additional lifecycle commands, bugfix and quick change workflows, pluggable tracker | Planned |
| 6. Organisation preset | A sample preset proving the extension points (templates, branch rules, tracker) | Planned |
| 7. First release | v0.1 | Planned |

Compatibility CI comes before features on purpose: it is the promise the project rests on, so every
feature after it is tested against new Spec Kit releases from the start.

## What is next

1. A prior-art sweep: check which candidate capabilities already exist elsewhere.
2. Draft the capability map, using what the upstream contract research found.
3. Decide the capability map.

Open questions waiting on that work include the workflow names, whether a release flow is in
scope, and the supported Spec Kit version range (to be settled before phase 3).

Live work items: [project board](https://github.com/users/vishalkhondre/projects/2). Current detail: [`docs/context/STATUS.md`](https://github.com/vishalkhondre/speckit-aisdlc/blob/main/docs/context/STATUS.md).
