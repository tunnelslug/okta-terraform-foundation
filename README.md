# okta-terraform-foundation

A **modular, multi-team, multi-state** Terraform template for managing an entire Okta organization as infrastructure-as-code.

> **Security:** This template authenticates to Okta **only** with an OAuth 2.0 / OIDC **API Services** app (`client_id` + `private_key` + `private_key_id`).  
> **Okta API tokens (SSWS) are not used and must not be added.** See [docs/AUTH.md](docs/AUTH.md).

**Repository name:** `okta-terraform-foundation`

**Start here for the full picture:** [docs/HOW_IT_WORKS.md](docs/HOW_IT_WORKS.md) (architecture, group rules, import/retrofit, day-2 operations).

Designed to be copied into any company and adapted quickly. Ownership is split so different teams can safely manage different parts of the same Okta org without sharing one giant state file.

---

## Why this template?

| Goal | How it’s solved |
|------|-----------------|
| Reuse at any company | Pure Terraform, no proprietary wrappers; clear placeholders |
| Modular | Small focused modules under `modules/` |
| Multi-owner | Independent **stacks** under `live/<env>/<stack>/`, each with its own state |
| Split state (S3 or GCS) | Every stack has its own backend key/prefix + example configs |
| Least privilege | Per-stack OAuth scopes and optional per-stack service apps |
| Safe cross-references | `terraform_remote_state` (read-only) between stacks |

---

## Architecture

```
okta-terraform-foundation/
├── modules/                      # Reusable building blocks (no state)
│   ├── groups/
│   ├── apps/{oauth,saml}/
│   ├── policies/{signon,mfa,password}/
│   ├── auth-servers/
│   ├── authenticators/
│   ├── network/
│   ├── trusted-origins/
│   ├── admin-roles/
│   ├── users/
│   └── governance/labels/
│
├── live/                         # Instantiated environments = where state lives
│   ├── dev/
│   │   ├── identity/             # State: okta/dev/identity/...
│   │   ├── apps/                 # State: okta/dev/apps/...
│   │   ├── policies/             # State: okta/dev/policies/...
│   │   ├── authz/                # State: okta/dev/authz/...
│   │   └── governance/           # State: okta/dev/governance/...
│   ├── staging/                  # Same stack layout (copy from dev)
│   └── prod/
│
├── shared/                       # Backend examples, shared fragments
│   ├── backend-s3.hcl.example
│   └── backend-gcs.hcl.example
│
├── docs/
│   ├── OWNERSHIP.md              # Team ownership & apply order
│   └── ADOPTING.md               # Company onboarding checklist
│
├── Makefile                      # init/plan/apply/bootstrap helpers
└── examples/minimal/             # Tiny single-file demo
```

### Stacks = ownership boundaries

| Stack | Owns | Typical owner |
|-------|------|---------------|
| **identity** | Groups, group rules, authenticators, network zones | Identity / IAM platform |
| **apps** | OAuth & SAML applications + group assignments | App / product IAM |
| **policies** | Session, app sign-on, MFA, password policies | Security / IAM |
| **authz** | Custom auth servers, scopes, claims, trusted origins | API / platform security |
| **governance** | OIG labels, custom admin roles, resource sets | Governance / GRC |

See [docs/OWNERSHIP.md](docs/OWNERSHIP.md) for remote-state wiring, apply order, and IAM recommendations.

---

## Quick start (one environment, one stack)

```bash
# 1. Enter a stack
cd live/dev/identity

# 2. Configure backend (S3 example)
cp backend.hcl.example backend.hcl
# edit bucket / key / region / dynamodb_table

# 3. Configure variables
cp terraform.tfvars.example terraform.tfvars
# edit org name, client id, etc.

# 4. Credentials (never commit)
export OKTA_API_CLIENT_ID="0oa..."
export OKTA_API_PRIVATE_KEY_ID="kid-..."
export OKTA_API_PRIVATE_KEY="$(cat /path/to/private.pem)"
# Optional aliases some provider versions also read: OKTA_CLIENT_ID, OKTA_PRIVATE_KEY

# 5. Init + plan + apply
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

Or use the Makefile:

```bash
make init  ENV=dev STACK=identity
make plan  ENV=dev STACK=identity
make apply ENV=dev STACK=identity
```

### GCS instead of S3

In each stack’s `versions.tf` change `backend "s3" {}` to `backend "gcs" {}`, then use `shared/backend-gcs.hcl.example`.

---

## Recommended apply order

```
identity  →  policies  →  apps  →  authz
                ↑
           governance (independent; can run anytime)
```

Downstream stacks read upstream outputs via `terraform_remote_state` (see `live/dev/apps/data.tf`).

---

## Adopting at a new company

See the full checklist in [docs/ADOPTING.md](docs/ADOPTING.md).

Short version:

1. Copy this repo.
2. Create S3+DynamoDB or GCS for state.
3. Create Okta OAuth service app(s); grant per-stack scopes.
4. Fill `backend.hcl` + `terraform.tfvars` under `live/dev/*`.
5. Apply `identity` first, then other stacks.
6. `make bootstrap-env ENV=staging` (and prod); adjust keys/tfvars.
7. Add CODEOWNERS so each team owns its stack path.
8. Wire CI per stack directory (not whole-repo apply).

---

## Modules reference

| Module | Purpose |
|--------|--------|
| `modules/groups` | Groups + dynamic group rules |
| `modules/apps/oauth` | OIDC / OAuth apps + group assignments |
| `modules/apps/saml` | SAML apps + group assignments |
| `modules/policies/signon` | Global session + app sign-on policies & rules |
| `modules/policies/mfa` | MFA / authenticator enrollment policies |
| `modules/policies/password` | Password policies & rules |
| `modules/auth-servers` | Custom auth servers, scopes, claims, policies, rules |
| `modules/authenticators` | Okta Verify, WebAuthn, Email, Phone, … |
| `modules/network` | Network zones |
| `modules/trusted-origins` | CORS / redirect trusted origins |
| `modules/admin-roles` | Custom admin roles + resource sets |
| `modules/governance/labels` | OIG governance labels |
| `modules/event-hooks` | Event hooks + log streams (e.g. app lifecycle tracking) |
| `modules/users` | Users (use sparingly; prefer SCIM) |

---

## Safety notes

- Always `terraform plan` and review before `apply`.
- Policy priorities must be explicit; use `depends_on` when creating multiple rules.
- Destroying resources can lock users out — prefer plan-destroy first.
- Keep Terraform credentials in a secrets manager; rotate private keys.
- Prefer **one service principal per stack** with minimal scopes.

---

## References

- [Okta Terraform Provider](https://registry.terraform.io/providers/okta/okta/latest)
- [Okta Developer – Terraform guides](https://developer.okta.com/docs/guides/)
- [docs/OWNERSHIP.md](docs/OWNERSHIP.md) – split-state & team ownership
- [docs/ADOPTING.md](docs/ADOPTING.md) – company onboarding checklist
- [docs/CI_AWS.md](docs/CI_AWS.md) – CodePipeline plan/apply + Slack notifications
- [docs/CI_GITHUB.md](docs/CI_GITHUB.md) – GitHub Actions lint / plan / drift
- [docs/APP_TRACKING.md](docs/APP_TRACKING.md) – track app create/update (TF + event hooks)
- GitHub Actions workflows: `.github/workflows/lint.yml`, `plan.yml`, `drift.yml`
