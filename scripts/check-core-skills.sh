#!/usr/bin/env bash
# Re-sync core skills at the pinned SHA and fail if committed files drifted.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

"${ROOT}/scripts/sync-core-skills.sh"

if ! git diff --quiet -- .cursor/skills; then
  echo "error: Core skills drifted from pinned upstream; run ./scripts/sync-core-skills.sh or bump scripts/upstream-sha.txt via the bump workflow." >&2
  git --no-pager diff --stat -- .cursor/skills >&2 || true
  git --no-pager diff -- .cursor/skills >&2 || true
  exit 1
fi

# Also catch untracked files under managed skill dirs (e.g. new upstream files).
if [[ -n "$(git ls-files --others --exclude-standard -- .cursor/skills)" ]]; then
  echo "error: Core skills drifted from pinned upstream (untracked files under .cursor/skills); run ./scripts/sync-core-skills.sh or bump scripts/upstream-sha.txt via the bump workflow." >&2
  git ls-files --others --exclude-standard -- .cursor/skills >&2 || true
  exit 1
fi

echo "OK: .cursor/skills matches pinned upstream."
