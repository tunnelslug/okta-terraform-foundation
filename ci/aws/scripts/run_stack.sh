#!/usr/bin/env bash
# Run terraform plan or apply for one env/stack and notify Slack.
set -euo pipefail
ACTION="${1:?usage: run_stack.sh plan|apply env/stack}"
STACK_PATH="${2:?}"
export STACK_PATH
REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
STACK_DIR="${REPO_ROOT}/live/${STACK_PATH}"
cd "$STACK_DIR"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NOTIFY="${SCRIPT_DIR}/slack_notify.sh"
BACKEND_CONFIG="${BACKEND_CONFIG_FILE:-backend.hcl}"
TFVARS="${TFVARS_FILE:-terraform.tfvars}"

if [[ -n "${OKTA_SECRET_ARN:-}" ]]; then
  SECRET_JSON="$(aws secretsmanager get-secret-value --secret-id "$OKTA_SECRET_ARN" --query SecretString --output text)"
  export TF_VAR_okta_client_id TF_VAR_okta_private_key TF_VAR_okta_private_key_id TF_VAR_okta_org_name TF_VAR_okta_base_url
  TF_VAR_okta_org_name="$(echo "$SECRET_JSON" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("org_name",""))')"
  TF_VAR_okta_base_url="$(echo "$SECRET_JSON" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("base_url","okta.com"))')"
  TF_VAR_okta_client_id="$(echo "$SECRET_JSON" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("client_id",""))')"
  TF_VAR_okta_private_key="$(echo "$SECRET_JSON" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("private_key",""))')"
  TF_VAR_okta_private_key_id="$(echo "$SECRET_JSON" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("private_key_id",""))')"
fi

if [[ -f "$BACKEND_CONFIG" ]]; then
  terraform init -input=false -backend-config="$BACKEND_CONFIG"
else
  terraform init -input=false
fi

case "$ACTION" in
  plan)
    [[ -x "$NOTIFY" ]] && "$NOTIFY" plan_start "Terraform plan starting" "Stack \`${STACK_PATH}\`" || true
    terraform plan -input=false ${TFVARS:+-var-file="$TFVARS"} || true
    ;;
  apply)
    [[ -x "$NOTIFY" ]] && "$NOTIFY" apply_start "Terraform apply starting" "Stack \`${STACK_PATH}\`" || true
    terraform apply -input=false -auto-approve ${TFVARS:+-var-file="$TFVARS"}
    [[ -x "$NOTIFY" ]] && "$NOTIFY" apply_ok "Apply succeeded" "Stack \`${STACK_PATH}\`" || true
    ;;
  *) echo "Unknown action"; exit 1 ;;
esac
