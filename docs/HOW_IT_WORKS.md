# How okta-terraform-foundation works

A single reference for engineers and platform teams: what this repo is, how the pieces fit together, and how to retrofit it onto almost any company or Okta org.

---

## 1. Purpose

Manage **Okta as infrastructure-as-code** with:

- **Modular** building blocks (groups, apps, policies, auth servers, governance, …)
- **Split state** so multiple teams can own different parts of one org safely
- **OIDC-only** authentication (API Services app + private key — **no API tokens**)
- A path to **adopt existing, manually managed** orgs via `terraform import`

Copy this repo into a new company, fill in backends and credentials, and grow stack-by-stack.

---

## 2. Mental model

```
                    ┌─────────────────────────────────────┐
                    │           Okta organization         │
                    └─────────────────────────────────────┘
                                      ▲
          ┌───────────────────────────┼───────────────────────────┐
          │                           │                           │
   ┌──────┴──────┐             ┌──────┴──────┐             ┌──────┴──────┐
   │ identity    │             │ policies    │             │ apps        │
   │ state file  │◄──remote───│ state file  │──remote────►│ state file  │
   └──────┬──────┘   state     └──────┬──────┘   state     └──────┬──────┘
          │                           │                           │
          └────────────┬──────────────┴────────────┬──────────────┘
                       │                           │
                ┌──────┴──────┐             ┌──────┴──────┐
                │ authz       │             │ governance  │
                │ state file  │             │ state file  │
                └─────────────┘             └─────────────┘

   Each box = live/<env>/<stack>/  with its own backend (S3 or GCS)
   Modules under modules/ are shared libraries (no state of their own)
```

| Layer | Path | Role |
|-------|------|------|
| **Modules** | `modules/*` | Reusable resource definitions; no backend |
| **Stacks** | `live/<env>/<stack>/` | Ownership + state boundary; calls modules |
| **Shared** | `shared/` | Backend examples, common provider notes |
| **Docs** | `docs/` | Ownership, auth, import, adoption |

---

## 3. Stacks (ownership boundaries)

| Stack | Owns in Okta | Typical team |
|-------|--------------|--------------|
| **identity** | Groups, **group rules**, authenticators, network zones | Identity / IAM platform |
| **apps** | OAuth/OIDC & SAML apps, app↔group assignments | App / product IAM |
| **policies** | Global session, app sign-on, MFA enrollment, password policies | Security / IAM |
| **authz** | Custom authorization servers, scopes, claims, trusted origins | API / platform security |
| **governance** | OIG labels, custom admin roles, resource sets, event hooks / log streams | Governance / GRC |

Cross-stack data flows **one way** via `terraform_remote_state` (read-only). Example: `apps` reads `group_ids` from `identity` and `app_signon_policy_ids` from `policies`.

Recommended apply order:

```
identity → policies → apps → authz
              ↑
         governance (independent)
```

Details: [OWNERSHIP.md](OWNERSHIP.md).

---

## 4. Group rules — yes, included

Dynamic membership is first-class in the **identity** stack.

**Module:** `modules/groups`  
**Resources:** `okta_group` + `okta_group_rule`

Example (already in `live/dev/identity/main.tf`):

```hcl
module "groups" {
  source = "../../../modules/groups"

  groups = [
    { name = "Engineering", description = "All engineering employees" },
  ]

  group_rules = [
    {
      name              = "Engineering-by-Department"
      group_assignments = ["Engineering"]   # names of groups in this module
      expression_value  = "user.department==\"Engineering\""
      status            = "ACTIVE"
    },
  ]
}
```

Rules are imported with:

```bash
terraform import 'module.groups.okta_group_rule.this["Engineering-by-Department"]' <rule_id>
```

See [IMPORT.md](IMPORT.md).

---

## 5. Authentication (secure by default)

Terraform **never** uses Okta SSWS API tokens in this template.

It uses an **Okta API Services (OIDC) application**:

- `client_id`
- `private_key` (PEM)
- `private_key_id` (kid)
- `scopes` (least privilege per stack)

```hcl
provider "okta" {
  org_name       = var.okta_org_name
  base_url       = var.okta_base_url
  client_id      = var.okta_client_id
  private_key    = var.okta_private_key
  private_key_id = var.okta_private_key_id
  scopes         = var.okta_scopes
}
```

- Generate keys: `make gen-oidc-key`
- Guard against regressions: `make check-no-api-token`
- Full guide: [AUTH.md](AUTH.md)

---

## 6. Split state (S3 or GCS)

Each `live/<env>/<stack>/` directory has its **own** state object, e.g.:

```
s3://company-tf-state/okta/dev/identity/terraform.tfstate
s3://company-tf-state/okta/dev/apps/terraform.tfstate
gs://company-tf-state/okta/prod/policies/...
```

Benefits:

- Smaller blast radius
- Teams apply without blocking each other on one lock
- IAM can grant write only to a team’s prefix
- CODEOWNERS can map paths to teams

Backend examples: `shared/backend-s3.hcl.example`, `shared/backend-gcs.hcl.example`, and each stack’s `backend.hcl.example`.

---

## 7. Retrofitting an existing (manual) org

You can adopt this template **without recreating** production objects.

1. **Copy** the template into the company repo.
2. **Wire** OIDC app + backend (S3/GCS).
3. **Start with identity** — declare existing groups/rules in HCL.
4. **`terraform import`** each object into the correct stack state.
5. **`terraform plan`** until clean (or only intentional diffs).
6. **Expand** to policies → apps → authz → governance.
7. **Freeze** console changes for managed resources; route change via PR.

Full import procedure, address formats, and drift handling: [IMPORT.md](IMPORT.md).  
Company checklist: [ADOPTING.md](ADOPTING.md).

### Strangler pattern

Leave unmanaged resources as-is. Only the objects you import become Terraform-owned. This is the safest path for large, long-lived Okta tenants.

---

## 8. Day-2 operations

| Situation | Action |
|-----------|--------|
| New group / app / policy | PR to the owning stack → plan → apply |
| Someone changed Okta in the UI | `terraform plan` in that stack → fix code or revert Okta |
| New environment (staging/prod) | `make bootstrap-env ENV=staging` then edit backends/tfvars |
| Rotate Terraform credentials | New key on API Services app; update secret; no `client_id` change ([AUTH.md](AUTH.md)) |
| Stop managing an object, keep it in Okta | `terraform state rm '…'` and remove from HCL ([IMPORT.md](IMPORT.md)) |

Makefile helpers:

```bash
make init   ENV=dev STACK=identity
make plan   ENV=dev STACK=apps
make apply  ENV=dev STACK=policies
make bootstrap-env ENV=prod
make gen-oidc-key
make check-no-api-token
```

---

## 9. What is intentionally out of scope (for now)

- Bulk workforce user lifecycle (prefer SCIM / HRIS; `modules/users` is break-glass only)
- Full assignment of governance labels to every resource (label **catalog** is in Terraform; some assignment flows may still need API/automation as the provider evolves)
- Non-Okta systems (AWS, Azure, etc.) — keep those in other repos/stacks
- Terragrunt / OpenTofu-specific wrappers — pure Terraform so it runs anywhere

You can extend modules without changing the stack/ownership model.

---

## 10. Retrofit-anywhere checklist

Use this when dropping the template into a new company:

- [ ] Repo copied; company naming applied
- [ ] Remote state bucket (S3+DynamoDB or GCS) created
- [ ] Okta **API Services** app(s) created; public key uploaded; private key in secrets manager
- [ ] Scopes granted per stack ([AUTH.md](AUTH.md))
- [ ] `live/dev/identity` backend + tfvars filled; OIDC env vars set
- [ ] Identity applied **or** existing groups/rules imported ([IMPORT.md](IMPORT.md))
- [ ] Remaining stacks brought up in order (policies → apps → authz → governance)
- [ ] `make bootstrap-env` for staging/prod; separate state keys
- [ ] CODEOWNERS / CI per stack path
- [ ] `make check-no-api-token` in CI
- [ ] Runbooks linked: this doc, OWNERSHIP, AUTH, IMPORT, ADOPTING

---

## 11. Doc map

| Doc | Contents |
|-----|----------|
| **[HOW_IT_WORKS.md](HOW_IT_WORKS.md)** (this file) | End-to-end model and retrofit story |
| [OWNERSHIP.md](OWNERSHIP.md) | Stack boundaries, remote state, apply order |
| [AUTH.md](AUTH.md) | OIDC private-key auth; no API tokens |
| [IMPORT.md](IMPORT.md) | Import existing resources; drift; strangler |
| [ADOPTING.md](ADOPTING.md) | Step-by-step company onboarding |
| [CI_AWS.md](CI_AWS.md) | AWS CodePipeline + Slack plan/apply notifications |
| GitHub Actions | `.github/workflows/lint.yml`, `plan.yml`, `drift.yml` |
| [../README.md](../README.md) | Quick start and architecture summary |

---

## 12. Design principles (summary)

1. **Modules are pure** — no backends, no env-specific values.
2. **Stacks own state** — one backend key per `live/<env>/<stack>`.
3. **Teams own stacks** — IAM + CODEOWNERS align with directories.
4. **OIDC only** — machine identity with scopes; never SSWS tokens.
5. **Import is normal** — existing orgs are first-class, not an afterthought.
6. **Plan before apply** — especially on policies and production apps.
7. **Remote state is read-only across stacks** — no cross-stack writes.
