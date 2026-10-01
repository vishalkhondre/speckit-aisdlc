# Roadmap

| Phase | Output | Status |
|---|---|---|
| 0. Discovery and decisions | Research on Spec Kit and related projects; decisions D-001 to D-022 | Done |
| 1. Upstream contract | What Spec Kit 1.0 guarantees: manifests, composition, hooks, workflow engine (pinned at v1.0.13) | Done |
| 2. Capability map | Every candidate capability marked keep, adapt or drop, reviewed by the specialist agents | In progress: map drafted and reviewed, awaiting decision |
| 3. Skeleton and compatibility CI | An empty bundle that installs on supported Spec Kit versions and the latest release, plus release checks | Planned |
| 4. MVP | Feature workflow with durable specs, per-feature session state, docs reconciliation, finish to PR | Planned |
| 5. Breadth | Additional lifecycle commands, bugfix and quick change workflows, pluggable tracker | Planned |
| 6. Organisation preset | A sample preset proving the extension points (templates, branch rules, tracker) | Planned |
| 7. First release | v0.1 | Planned |

Compatibility CI comes before features on purpose: it is the promise the project rests on, so every
feature after it is tested against new Spec Kit releases from the start.

## What is next

The capability map is drafted and has been reviewed by the software architect and the agile delivery
consultant ([map](https://github.com/vishalkhondre/speckit-aisdlc/blob/main/docs/research/capability-map.md)).
It is a proposal until it is decided. Deployment is out of scope (D-028).

1. Decide the capability map, including whether documentation reconciliation is in the MVP or the next phase.
2. Then phase 3: an empty bundle, configuration, and compatibility CI.

Still open: the workflow names, and confirming the provisional supported Spec Kit range (D-024) in phase 3.

Live work items: [project board](https://github.com/users/vishalkhondre/projects/2). Current detail: [`docs/context/STATUS.md`](https://github.com/vishalkhondre/speckit-aisdlc/blob/main/docs/context/STATUS.md).
