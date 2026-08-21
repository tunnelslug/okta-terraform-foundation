#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
REPO="${GITHUB_REPO:-tunnelslug/okta-terraform-foundation}"
BRANCH="${BRANCH:-main}"

if command -v gh >/dev/null; then
  git init 2>/dev/null || true
  git branch -M "$BRANCH"
  git remote remove origin 2>/dev/null || true
  git remote add origin "https://github.com/${REPO}.git"
  git add -A
  git status
  git commit -m "Import full okta-terraform-foundation" || true
  git push -u origin "$BRANCH"
else
  echo "Install GitHub CLI (gh) and run: gh auth login"
  exit 1
fi
