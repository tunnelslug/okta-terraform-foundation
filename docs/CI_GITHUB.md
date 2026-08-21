# GitHub Actions CI

Workflows shipped with **okta-terraform-foundation**:

| Workflow | Trigger | Purpose |
|----------|---------|--------|
| `lint.yml` | PR / push (TF paths) | `fmt`, `validate`, `tflint`, no API tokens |
| `plan.yml` | PR touching `live/` or `modules/` | Detect changed stacks; plan if OIDC secrets exist |
| `drift.yml` | Weekday schedule + manual | Plan configured stacks; Slack on drift/fail |

## Repository secrets (optional but required for real plans)

| Secret | Purpose |
|--------|--------|
| `OKTA_ORG_NAME` | Okta org |
| `OKTA_BASE_URL` | `okta.com` / `oktapreview.com` / … |
| `OKTA_API_CLIENT_ID` | API Services client ID |
| `OKTA_API_PRIVATE_KEY` | PEM private key |
| `OKTA_API_PRIVATE_KEY_ID` | Key ID (`kid`) |
| `SLACK_WEBHOOK_URL` | Optional Slack incoming webhook |
| `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_REGION` | Only if state backend is S3 |

Without Okta secrets, **lint still runs**; plan/drift skip with a notice so the template repo stays usable publicly.

## Local equivalent

```bash
make ci-local
```
