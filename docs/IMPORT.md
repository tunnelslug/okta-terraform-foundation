# Importing existing Okta resources into Terraform

Most real Okta orgs are **not** greenfield. They were built in the Admin Console, via API scripts, or by a previous tool. This template is designed to be **retrofitted**: you describe resources in code, then `terraform import` so state matches reality **without recreating** them.

Use this process whenever:

- The org was mostly managed manually
- Someone changed a resource in the Admin Console (drift)
- You are adopting this template on an existing tenant
- You need to bring a subset of objects under Terraform first (strangler pattern)

---

## Principles

1. **Import does not change Okta** — it only maps an existing object ID into Terraform state.
2. **Code must match reality** — after import, the resource block should describe the object as it is (or you plan a deliberate change).
3. **One stack at a time** — import into the stack that owns that resource type (`identity` for groups, `apps` for applications, etc.).
4. **Never import the same object into two states** — split-state means clear ownership.

---

## High-level workflow

```
1. Inventory          What exists in Okta today?
2. Write config       Add matching resource blocks (or module inputs)
3. terraform import   Bind each object ID to a resource address
4. terraform plan     Expect "no changes" (or only intentional diffs)
5. Reconcile drift    Adjust code or Okta until plan is clean
6. Apply only when    You intend to change Okta
```

---

## 1. Inventory

Useful sources:

- Okta Admin Console (Directory, Applications, Security → Policies, …)
- Okta API / Reports
- Provider data sources (read-only), e.g. `data.okta_groups`, `data.okta_app`

Record at least: **name/label**, **ID**, and owning **stack**.

Example inventory snippet:

| Type | Name | ID | Stack |
|------|------|-----|-------|
| Group | Engineering | `00g1a2b3c4d5e6f7g8h9` | identity |
| Group rule | Engineering-by-Department | `0pr9i8u7y6t5r4e3w2q1` | identity |
| OAuth app | Internal-Dashboard | `0oa1z2x3c4v5b6n7m8k9` | apps |
| App sign-on policy | Default-App-SignOn | `rst1q2w3e4r5t6y7u8i9` | policies |

---

## 2. Write configuration first

Import requires the resource to **exist in configuration**. Add it to the right stack’s module inputs or resources.

**Groups (identity stack)** — `live/dev/identity/main.tf`:

```hcl
module "groups" {
  source = "../../../modules/groups"

  groups = [
    {
      name        = "Engineering"
      description = "All engineering employees"  # match Okta
    },
  ]

  group_rules = [
    {
      name              = "Engineering-by-Department"
      group_assignments = ["Engineering"]
      expression_value  = "user.department==\"Engineering\""  # match Okta
      status            = "ACTIVE"
    },
  ]
}
```

**OAuth app (apps stack)** — match `label`, `type`, grant types, redirect URIs, etc. as closely as possible before import.

---

## 3. Import syntax

Generic form:

```bash
terraform import ADDRESS ID
```

With modules / `for_each`, the address includes the module path and key:

```bash
# From inside live/dev/identity
terraform import 'module.groups.okta_group.this["Engineering"]' 00g1a2b3c4d5e6f7g8h9

terraform import 'module.groups.okta_group_rule.this["Engineering-by-Department"]' 0pr9i8u7y6t5r4e3w2q1
```

```bash
# From inside live/dev/apps
terraform import 'module.oauth_apps.okta_app_oauth.this["Internal-Dashboard"]' 0oa1z2x3c4v5b6n7m8k9
```

Always run imports from the **stack directory** that owns the resource, with that stack’s backend initialized.

---

## 4. Common resource → import ID map

| Resource | Import ID | Example address |
|----------|-----------|-----------------|
| `okta_group` | Group ID | `module.groups.okta_group.this["Engineering"]` |
| `okta_group_rule` | Group rule ID | `module.groups.okta_group_rule.this["Engineering-by-Department"]` |
| `okta_app_oauth` | App ID | `module.oauth_apps.okta_app_oauth.this["Internal-Dashboard"]` |
| `okta_app_saml` | App ID | `module.saml_apps.okta_app_saml.this["AWS"]` |
| `okta_app_group_assignments` | App ID | `module.oauth_apps.okta_app_group_assignments.this["Internal-Dashboard"]` |
| `okta_policy_signon` | Policy ID | `module.signon.okta_policy_signon.global["Default-Global-Session"]` |
| `okta_policy_rule_signon` | `policy_id/rule_id` | see provider docs |
| `okta_app_signon_policy` | Policy ID | `module.signon.okta_app_signon_policy.this["Default-App-SignOn"]` |
| `okta_app_signon_policy_rule` | `policy_id/rule_id` | see provider docs |
| `okta_policy_mfa` | Policy ID | `module.mfa.okta_policy_mfa.this["Default-MFA-Enrollment"]` |
| `okta_auth_server` | Auth server ID | `module.auth_servers.okta_auth_server.this["api-authorization-server"]` |
| `okta_auth_server_scope` | `auth_server_id/scope_id` | provider docs |
| `okta_auth_server_claim` | `auth_server_id/claim_id` | provider docs |
| `okta_auth_server_policy` | `auth_server_id/policy_id` | provider docs |
| `okta_auth_server_policy_rule` | `auth_server_id/policy_id/rule_id` | provider docs |
| `okta_authenticator` | Authenticator ID | `module.authenticators.okta_authenticator.this["okta_verify"]` |
| `okta_network_zone` | Zone ID | `module.network.okta_network_zone.this["Corporate-HQ"]` |
| `okta_trusted_origin` | Origin ID | `module.trusted_origins.okta_trusted_origin.this["Dashboard-Dev"]` |
| `okta_label` | Label ID | `module.labels.okta_label.this["Compliance"]` |
| `okta_admin_role_custom` | Role ID | `module.admin_roles.okta_admin_role_custom.this["App-Admin-Limited"]` |
| `okta_resource_set` | Resource set ID | `module.admin_roles.okta_resource_set.this["Engineering-Apps-and-Groups"]` |

IDs are visible in the Admin Console URL, or via API/`terraform state` after a partial import. When unsure, check the resource page on the [Terraform Registry](https://registry.terraform.io/providers/okta/okta/latest/docs).

---

## 5. After import: make `plan` clean

```bash
cd live/dev/identity
terraform plan
```

| Plan result | Meaning | Action |
|-------------|---------|--------|
| No changes | Config matches Okta | Done for that object |
| Update in-place | Config differs from Okta | Align HCL to Okta **or** accept the change and apply |
| Force replace | Immutable field differs | Fix config; avoid apply until intentional |
| Destroy | Resource in state but not in config | Restore config or `state rm` deliberately |

**Tip:** Import in small batches (e.g. all groups, then all rules). Run `plan` after each batch.

---

## 6. Drift from Admin Console changes

If someone edits Okta outside Terraform:

```bash
cd live/<env>/<stack>
terraform plan
```

- **Prefer code as source of truth:** adjust Okta by applying, or  
- **Prefer Okta as temporary truth:** update HCL to match, then plan is clean again.

For emergency hotfixes in the console, still open a follow-up PR that imports or reconciles so state does not lie.

---

## 7. Strangler (gradual) adoption

You do **not** need to import everything on day one.

Suggested order for an existing org:

1. **identity** – groups + group rules (low risk, high leverage)
2. **governance** – labels / roles (often net-new)
3. **policies** – after groups exist in state
4. **apps** – app by app, starting with non-prod
5. **authz** – custom auth servers last if already complex

Resources not yet in Terraform can keep being managed manually until their turn.

---

## 8. Practical import script pattern

```bash
#!/usr/bin/env bash
# scripts/import-groups.sh — run from live/dev/identity
set -euo pipefail

terraform import 'module.groups.okta_group.this["Engineering"]' '00g...'
terraform import 'module.groups.okta_group.this["Security-Admins"]' '00g...'
terraform import 'module.groups.okta_group_rule.this["Engineering-by-Department"]' '0pr...'

terraform plan
```

Commit the script next to the stack if the migration is large; delete it after cutover.

---

## 9. Removing a resource from Terraform only

To stop managing an object **without deleting it from Okta**:

```bash
terraform state rm 'module.groups.okta_group.this["Engineering"]'
```

Then remove it from configuration. Okta keeps the group; Terraform forgets it.

---

## 10. Checklist before first production import

- [ ] Correct stack directory and backend (`terraform init`)
- [ ] OIDC credentials work (`terraform plan` on empty or partial config)
- [ ] Resource addresses match `for_each` keys exactly (quotes matter)
- [ ] Config attributes match production (especially policy priorities)
- [ ] `terraform plan` reviewed by the owning team
- [ ] No second state file claims the same object IDs
