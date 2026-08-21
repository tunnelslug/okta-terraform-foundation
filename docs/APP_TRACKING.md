# Tracking Okta application creates and modifications

Three layers:

1. **Terraform apps stack** — plan/apply, git history, CI, drift job
2. **Okta System Log** — `application.lifecycle.create|update|delete|activate|deactivate`
3. **Event hooks / log streams** — `modules/event-hooks` in the governance stack

## Governance labels

Label **definitions** are Terraform (`okta_label`). **Assignment** to app/group ORNs uses the Governance API via `scripts/assign_resource_labels.sh` until a native provider resource exists.

```bash
export LABEL_VALUE_IDS="lblo...,lblo..."
export RESOURCE_ORNS="orn:okta:idp:{orgId}:apps:oidc:{appId},orn:okta:directory:{orgId}:groups:{groupId}"
./scripts/assign_resource_labels.sh
```
