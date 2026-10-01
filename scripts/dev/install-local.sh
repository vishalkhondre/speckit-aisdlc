#!/usr/bin/env bash
# Install aisdlc from this checkout into a Spec Kit project (#16).
#
# A local bundle supplies only its manifest; Spec Kit resolves components from
# installed components or catalogs. So each component is first added from its
# directory, then the bundle is installed over them (it records itself and
# skips the components as already present).
#
# Usage: scripts/dev/install-local.sh [project-dir]   (default: current dir)
# Requires: `specify` on PATH (or SPECIFY=/path/to/specify), project already
# initialised with `specify init`.

set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
project="${1:-.}"
specify="${SPECIFY:-specify}"

cd "$project"
[ -d .specify ] || { echo "Not a Spec Kit project: $(pwd) (run 'specify init' first)" >&2; exit 1; }

"$specify" extension add --dev "$repo/extension"
"$specify" preset add --dev "$repo/preset"
"$specify" workflow add --dev "$repo/workflows/aisdlc-feature"
"$specify" bundle install "$repo/bundle"
