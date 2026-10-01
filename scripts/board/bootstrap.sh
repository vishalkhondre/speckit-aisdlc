#!/usr/bin/env bash
# Bootstrap the speckit-aisdlc work-tracking setup (D-017).
#
# Creates labels, milestones for phases 0-7, and the first issues for phases 0-2,
# and adds every issue to GitHub Project #2 (owner: vishalkhondre).
#
# Safe to re-run: existing labels are updated, existing milestones and issues
# (matched by exact title) are skipped.
#
# Normally run by the "Bootstrap project board" GitHub Action
# (.github/workflows/board-bootstrap.yml), which supplies GH_TOKEN from the WIKI_TOKEN secret.
# To run elsewhere: gh CLI logged in with the `repo` and `project` scopes, then
#   bash scripts/board/bootstrap.sh

set -euo pipefail

REPO="vishalkhondre/speckit-aisdlc"
OWNER="vishalkhondre"
PROJECT_NUMBER=2

command -v gh >/dev/null || { echo "gh CLI not found" >&2; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "gh is not authenticated: set GH_TOKEN or run 'gh auth login'" >&2; exit 1; }
gh project view "$PROJECT_NUMBER" --owner "$OWNER" >/dev/null 2>&1 \
  || { echo "Cannot read project #$PROJECT_NUMBER: the token needs the 'project' scope" >&2; exit 1; }

# Retry a gh call with back-off, printing GitHub's error on each failure.
retry() {
  local attempt out
  for attempt in 1 2 3 4; do
    if out=$("$@" 2>&1); then printf '%s\n' "$out"; return 0; fi
    echo "  attempt $attempt failed: $out" >&2
    [ "$attempt" -lt 4 ] && sleep $((attempt * 15))
  done
  return 1
}

# ---------------------------------------------------------------- labels
label() { retry gh label create "$1" --repo "$REPO" --color "$2" --description "$3" --force >/dev/null; echo "label: $1"; }
label research        "5319e7" "Investigation or analysis"
label decision        "fbca04" "Produces a decision for docs/context/DECISIONS.md"
label needs-decision  "d93f0b" "Waiting on the user to decide"
label build           "0e8a16" "Code, manifests, workflows or CI"
label docs            "0075ca" "Documentation or wiki"
label chore           "c5def5" "Setup and housekeeping"

# ---------------------------------------------------------------- milestones
existing_milestones=$(gh api "repos/$REPO/milestones?state=all&per_page=100" --jq '.[].title')
milestone() {
  if grep -Fxq "$1" <<<"$existing_milestones"; then
    echo "milestone exists: $1"
  else
    retry gh api "repos/$REPO/milestones" -f title="$1" -f description="$2" >/dev/null
    echo "milestone created: $1"
  fi
}
M0="Phase 0 · Discovery and decisions"
M1="Phase 1 · Upstream contract"
M2="Phase 2 · Capability map"
milestone "$M0" "Research on Spec Kit and related projects; decisions D-001 onward."
milestone "$M1" "What Spec Kit 1.0 guarantees: manifests, composition, hooks, workflow engine."
milestone "$M2" "Every candidate capability marked keep / adapt / drop, reviewed by the specialist agents."
milestone "Phase 3 · Skeleton and compatibility CI" "Empty bundle that installs on supported Spec Kit versions and the latest release, plus release checks."
milestone "Phase 4 · MVP" "Feature workflow with durable specs, per-feature session state, docs reconciliation, finish to PR."
milestone "Phase 5 · Breadth" "Additional lifecycle commands, bugfix and quick change workflows, pluggable tracker."
milestone "Phase 6 · Organisation preset" "Sample preset proving the extension points (templates, branch rules, tracker)."
milestone "Phase 7 · First release" "v0.1."

# ---------------------------------------------------------------- issues
# title<TAB>url for every existing issue, so re-runs can still add them to the project.
existing_issues=$(gh issue list --repo "$REPO" --state all --limit 500 --json title,url \
  --jq '.[] | "\(.title)\t\(.url)"')
# Adds an issue to the project. "Already exists" counts as success: the project's
# Auto-add workflow often adds a new issue before this script does.
add_to_project() {
  local attempt out
  for attempt in 1 2 3 4; do
    if out=$(gh project item-add "$PROJECT_NUMBER" --owner "$OWNER" --url "$1" 2>&1); then return 0; fi
    if grep -qi "already exists" <<<"$out"; then return 0; fi
    echo "  attempt $attempt failed: $out" >&2
    [ "$attempt" -lt 4 ] && sleep $((attempt * 15))
  done
  return 1
}
issue() {  # title, milestone, labels (comma-separated), body
  local title="$1" ms="$2" labels="$3" body="$4" url
  url=$(awk -F'\t' -v t="$title" '$1 == t { print $2; exit }' <<<"$existing_issues")
  if [ -n "$url" ]; then
    add_to_project "$url"
    echo "issue exists (ensured on board): $title"
    return
  fi
  url=$(retry gh issue create --repo "$REPO" --title "$title" --milestone "$ms" --label "$labels" --body "$body" | tail -1)
  add_to_project "$url"
  echo "issue created: $title -> $url"
  sleep 3   # pace content creation
}

issue "Set up the project board views and built-in workflows" "$M0" "chore" \
"Manual setup in GitHub Project #2 (D-017).

- [ ] Workflows (project ⋯ menu → Workflows): enable **Auto-add to project** for this repo, **Item closed → Done**, **Pull request merged → Done**
- [ ] Board view: Todo · In progress · In review · Done
- [ ] Roadmap view grouped by milestone

Owner: the user."

issue "Name the aisdlc workflows" "$M0" "decision,needs-decision" \
"The workflow names \`aisdlc-feature\`, \`aisdlc-bugfix\`, \`aisdlc-quick\` and \`aisdlc-onboard\` are placeholders (STATUS.md open question 2).

**Done when:** the user picks final names and they are recorded as a decision in \`docs/context/DECISIONS.md\`."

issue "Pin the Spec Kit 1.0 public contract" "$M1" "research" \
"Fill the TODO section of \`docs/research/upstream-spec-kit.md\` from upstream sources (not memory).

- [ ] Manifest schemas: extension, preset (replace / prepend / append), workflow, bundle
- [ ] Hook events and the \`EXECUTE_COMMAND\` protocol; which integrations support it
- [ ] Workflow engine: step types, expressions, run-state layout
- [ ] Can the engine apply behaviour per run only (D-010)?
- [ ] Changes and deprecations between 0.7.x and 1.0.x (CHANGELOG)
- [ ] \`software-architect\` review saved to \`docs/reviews/\`

**Done when:** every item is answered with a source link, and any internal dependency is listed under *Internal dependencies*."

issue "Prior-art sweep of candidate capabilities" "$M2" "research" \
"Run \`prior-art-researcher\` for each candidate: verify, review, secure, deploy, retrospective, guard, router, ship, brownfield onboarding, remediate, docs reconciliation, quick change flow, decision log and handoffs, per-feature session state.

**Done when:** one report per candidate (or one combined report) is saved to \`docs/reviews/\`, each ending with ADOPT / DEPEND / BORROW / BUILD."

issue "Draft the capability map" "$M2" "research" \
"Create \`docs/research/capability-map.md\` from the prior-art sweep: each candidate → keep / adapt / drop, target mechanism (extension command, preset prepend/append, workflow step, hook), organisation-preset extension point, and de-branded name.

- [ ] Draft written
- [ ] \`software-architect\` review saved to \`docs/reviews/\`
- [ ] \`agile-delivery-consultant\` review saved to \`docs/reviews/\`

Depends on: *Pin the Spec Kit 1.0 public contract*, *Prior-art sweep of candidate capabilities*."

issue "Decide the capability map" "$M2" "decision,needs-decision" \
"The user reviews the capability map and both review reports and decides what aisdlc builds (D-015), including whether a release flow is in scope.

**Done when:** the outcome is recorded in \`docs/context/DECISIONS.md\` and the map is marked accepted."

echo "Done."
