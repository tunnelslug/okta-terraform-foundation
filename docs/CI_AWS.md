# AWS CodePipeline + Slack notifications

Scaffold for an automated pipeline that:

1. Triggers when `live/<env>/<stack>/` (or optionally `modules/`) changes  
2. Runs **terraform plan** on only the affected stacks  
3. Posts a **Slack plan notification** (with CodeBuild + CodePipeline links)  
4. Waits for **manual approval**  
5. Runs **terraform apply** and posts a **Slack apply notification** (success/fail + links)

```
GitHub push (main)
       │
       ▼
 CodePipeline Source
       │
       ▼
 CodeBuild PLAN  ──────► Slack: plan_start / plan_ok | plan_changes | plan_fail
       │                         + links to CodeBuild log & CodePipeline
       ▼
 Manual Approval (SNS optional)
       │
       ▼
 CodeBuild APPLY ──────► Slack: apply_start / apply_ok | apply_fail
                         + links to CodeBuild log & CodePipeline
```

---

## Layout

```
ci/aws/
├── codebuild/
│   ├── buildspec-plan.yml
│   └── buildspec-apply.yml
├── scripts/
│   ├── detect_changed_stacks.sh   # git diff → env/stack list
│   ├── run_stack.sh               # terraform init/plan/apply + Slack
│   └── slack_notify.sh            # Incoming Webhook formatter
└── terraform/                     # Pipeline infrastructure
    ├── codepipeline.tf
    ├── codebuild.tf
    ├── iam.tf
    ├── s3.tf
    └── terraform.tfvars.example
```

---

## Prerequisites

1. **GitHub → CodeStar Connection** in AWS (Console → Developer Tools → Connections).  
2. **S3 bucket** for Okta Terraform state + **DynamoDB** lock table.  
3. **Secrets Manager** secrets:
   - **Slack webhook** – plain URL string, *or* JSON `{"webhook_url":"https://hooks.slack.com/..."}`  
   - **Okta OIDC credentials** – JSON:
     ```json
     {
       "org_name": "dev-123456",
       "base_url": "oktapreview.com",
       "client_id": "0oa...",
       "private_key": "-----BEGIN RSA PRIVATE KEY-----\\n...\\n-----END RSA PRIVATE KEY-----",
       "private_key_id": "kid-..."
     }
     ```
4. Slack **Incoming Webhook** for the target channel.

Still **no Okta API tokens** — the pipeline uses the same OIDC client_id + private_key as local applies ([AUTH.md](AUTH.md)).

---

## Deploy the pipeline

```bash
cd ci/aws/terraform
cp terraform.tfvars.example terraform.tfvars
# edit: GitHub, CodeStar ARN, state bucket, secret ARNs

terraform init
terraform plan
terraform apply
```

Outputs include `console_pipeline_url`.

---

## How stack detection works

`detect_changed_stacks.sh` diffs against `origin/main` (configurable) and lists unique:

```
live/<env>/<stack>/...
→ dev/identity
→ dev/apps
```

Only those stacks are planned/applied. Unrelated paths do not trigger Okta changes.

Optional: set `plan_on_module_change = true` so a change under `modules/` re-plans all stacks in `default_env`.

---

## Slack message contents

Each notification includes:

| Field | Example |
|-------|--------|
| Status | Plan: changes detected / Apply succeeded |
| Stack | `dev/identity` |
| Pipeline name | `okta-terraform-pipeline` |
| Build ID | CodeBuild id |
| Snippet | Last lines of plan/apply output |
| Links | **CodeBuild log** \| **CodePipeline** |

Statuses: `plan_start`, `plan_ok`, `plan_changes`, `plan_fail`, `apply_start`, `apply_ok`, `apply_fail`.

---

## Manual approval

When `enable_apply_stage = true`, the pipeline pauses after Plan. Approvers use the CodePipeline console (or SNS email if you subscribe the approval topic).

```bash
aws sns subscribe \
  --topic-arn "$(terraform -chdir=ci/aws/terraform output -raw approval_sns_topic_arn)" \
  --protocol email \
  --notification-endpoint platform-team@example.com
```

---

## Security notes

- CodeBuild role can read only the two Secrets Manager ARNs you pass in.  
- State access is limited to your Terraform state bucket + lock table.  
- Okta credentials remain OIDC private_key_jwt — never SSWS API tokens.  
- Prefer separate Okta API Services apps / secrets per environment (dev vs prod pipelines).

---

## Local dry-run of scripts

```bash
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/..."
export STACK_PATH="dev/identity"
ci/aws/scripts/slack_notify.sh plan_start "Local test" "hello"

BASE_REF=origin/main ci/aws/scripts/detect_changed_stacks.sh
```

---

## Extending

| Idea | Approach |
|------|----------|
| Per-stack pipelines | Duplicate CodeBuild projects filtered by path (`live/dev/apps/**`) |
| Plan-only on PR | Second pipeline on non-main branches; `enable_apply_stage = false` |
| GCS / Google | Mirror this pattern with Cloud Build + Pub/Sub → Slack |
| Atlantis / Spacelift | Keep `scripts/` and Slack formatter; swap orchestrator |

This scaffold is intentionally example-grade: wire real ARNs, tighten IAM, and add branch protections before production use.
