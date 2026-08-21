#!/usr/bin/env bash
set -euo pipefail
STATUS="${1:?}"
TITLE="${2:?}"
DETAILS="${3:-}"
WEBHOOK="${SLACK_WEBHOOK_URL:?}"
BUILD_URL="${CODEBUILD_BUILD_URL:-${GITHUB_SERVER_URL:-}/}"
curl -sS -X POST -H 'Content-type: application/json' \
  --data "{\"text\":\"*[${STATUS}] ${TITLE}*\\n${DETAILS}\\n${BUILD_URL}\"}" \
  "$WEBHOOK" >/dev/null
echo "Slack: $STATUS — $TITLE"
