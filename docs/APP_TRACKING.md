# Tracking Okta application creates and modifications

There are **three layers**. Use them together.

## 1. Terraform is the control plane (apps stack)

All OAuth/SAML apps managed under `live/<env>/apps/` are declared in code.

| Action | How you see it |
|--------|----------------|
| Create / update / delete via TF | `terraform plan` / `apply` in the **apps** stack |
| PR review | Git history + CODEOWNERS on `live/*/apps/` |
| CI | GHA `plan.yml` or CodePipeline plan → Slack |
| Drift (console edit) | Scheduled `drift.yml` or `terraform plan` in apps stack |

If an app is **not** in Terraform, it will not appear in plan until you import it ([IMPORT.md](IMPORT.md)).

## 2. Okta System Log (source of truth for *all* changes)

Every app lifecycle event is logged, whether it came from Terraform, Admin Console, or API:

- `application.lifecycle.create`
- `application.lifecycle.update`
- `application.lifecycle.delete`
- `application.lifecycle.activate`
- `application.lifecycle.deactivate`

Filter in Admin Console → **Reports → System Log**, or API:

```text
eventType eq "application.lifecycle.create"
or eventType eq "application.lifecycle.update"
```

## 3. Event hooks + log streams (push notifications)

**Module:** `modules/event-hooks`  
**Wired in:** `live/dev/governance` (optional; set `event_hook_uri`)

```hcl
# terraform.tfvars
event_hook_uri        = "https://hooks.example.com/okta/app-lifecycle"
event_hook_auth_type  = "HEADER"
event_hook_auth_key   = "Authorization"
event_hook_auth_value = "Bearer ..."   # from secrets manager in real use
```

That registers an `okta_event_hook` for the application lifecycle events above. Your endpoint receives JSON payloads when apps are created/updated/deleted **anywhere** in the org (including outside Terraform).

Optional: `log_streams` for **aws_eventbridge** or **splunk_cloud_logstreaming** (full System Log pipe to SIEM).

After apply, **verify** the event hook in Okta Admin (one-time challenge).

### Required scopes (governance stack)

```
okta.eventHooks.manage
okta.eventHooks.read
okta.logStreams.manage   # if using log streams
okta.logStreams.read
```

## Governance labels (related)

OIG labels for categorizing apps/groups live under:

- `modules/governance/labels`
- `live/dev/governance` → `module.labels`

Labels classify resources; event hooks **notify** on changes. Both are in the governance stack.

## Assigning governance labels to apps and groups

Label **definitions** are Terraform (`okta_label`). **Assignment** to app/group ORNs uses the Governance API:

```bash
export LABEL_VALUE_IDS="lblo...,lblo..."
export RESOURCE_ORNS="orn:okta:idp:{orgId}:apps:oidc:{appId},orn:okta:directory:{orgId}:groups:{groupId}"
# plus OKTA_API_CLIENT_ID / PRIVATE_KEY / PRIVATE_KEY_ID / ORG_NAME
./scripts/assign_resource_labels.sh
```

See `scripts/assign_resource_labels.sh`. Run after apps/identity apply, or from CI.

## Recommended setup

1. Manage apps in the **apps** stack (IaC).  
2. Enable **event hook** (or EventBridge stream) for app lifecycle.  
3. Keep **drift** CI on so console-only app edits still surface.  
4. Optionally tag apps with governance labels (Compliance, Environment, …).
