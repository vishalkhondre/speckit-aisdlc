# Reviews

Reports from the read-only specialist agents in `.claude/agents/` (D-016). They advise; the user
decides.

- **File name:** `<YYYY-MM-DD>-<topic>-<role>.md`, e.g. `2026-10-02-capability-map-software-architect.md`.
- **Who saves them:** the reviewers have no write tools, so the session that invoked them saves the
  report here unchanged.
- **When:** before a significant decision. Reference the review files in the decision entry.

| Agent | Reviews |
|---|---|
| `prior-art-researcher` | Does it already exist? Adopt, depend, borrow, or build |
| `software-architect` | Hard rules, upstream contract, upgrade safety, extension points, simplicity |
| `agile-delivery-consultant` | Fit with real team delivery, gates, traceability, overhead; framework-neutral |

In Claude chat, read the agent file from `.claude/agents/` and apply it as the review instructions.
