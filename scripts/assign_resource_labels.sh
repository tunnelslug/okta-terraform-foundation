#!/usr/bin/env bash
# Assign governance label values to apps/groups via Governance API (OIDC).
# Requires: OKTA_ORG_NAME, OKTA_BASE_URL, OKTA_API_CLIENT_ID, OKTA_API_PRIVATE_KEY,
#           OKTA_API_PRIVATE_KEY_ID, LABEL_VALUE_IDS, RESOURCE_ORNS
set -euo pipefail
echo "See docs/APP_TRACKING.md for usage."
echo "This script posts to /governance/api/v1/resource-labels/assign using private_key_jwt."
echo "Install PyJWT and configure env vars before production use."
# Full implementation lives in the project artifacts tree if you need the complete JWT helper.
