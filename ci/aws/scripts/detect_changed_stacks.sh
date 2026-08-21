#!/usr/bin/env bash
# Detect which live/<env>/<stack> paths changed in this commit range.
set -euo pipefail

BASE_REF="${BASE_REF:-origin/main}"
HEAD_REF="${HEAD_REF:-HEAD}"
REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
OUT_FILE="${CHANGED_STACKS_FILE:-/tmp/changed_stacks.txt}"

cd "$REPO_ROOT"

if ! git rev-parse --verify "$BASE_REF" >/dev/null 2>&1; then
  BASE_REF="$(git rev-list --max-parents=0 HEAD | tail -1)"
fi

echo "Comparing ${BASE_REF}...${HEAD_REF}"

mapfile -t CHANGED < <(
  git diff --name-only "${BASE_REF}...${HEAD_REF}" -- 'live/' \
    | sed -n 's|^live/\([^/]*\)/\([^/]*\)/.*|\1/\2|p' \
    | sort -u
)

if [[ "${FORCE_ALL_ON_MODULE_CHANGE:-false}" == "true" ]]; then
  if git diff --name-only "${BASE_REF}...${HEAD_REF}" -- 'modules/' | grep -q .; then
    ENV="${DEFAULT_ENV:-dev}"
    for s in identity apps policies authz governance; do
      CHANGED+=("${ENV}/${s}")
    done
    mapfile -t CHANGED < <(printf '%s\n' "${CHANGED[@]}" | sort -u)
  fi
fi

if [[ ${#CHANGED[@]} -eq 0 ]]; then
  echo "No live/<env>/<stack> changes detected."
  : > "$OUT_FILE"
  exit 0
fi

printf '%s\n' "${CHANGED[@]}" | tee "$OUT_FILE"
echo "Wrote $(wc -l < "$OUT_FILE") stack(s) to $OUT_FILE"
