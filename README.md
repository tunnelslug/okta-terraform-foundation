# okta-terraform-foundation

A **modular, multi-team, multi-state** Terraform template for managing an entire Okta organization as infrastructure-as-code.

> **Security:** This template authenticates to Okta **only** with an OAuth 2.0 / OIDC **API Services** app (`client_id` + `private_key` + `private_key_id`).  
> **Okta API tokens (SSWS) are not used and must not be added.** See [docs/AUTH.md](docs/AUTH.md).

**Repository name:** `okta-terraform-foundation`

**Start here for the full picture:** [docs/HOW_IT_WORKS.md](docs/HOW_IT_WORKS.md) (architecture, group rules, import/retrofit, day-2 operations).

Designed to be copied into any company and adapted quickly. Ownership is split so different teams can safely manage different parts of the same Okta org without sharing one giant state file.

---

## Why this template?

| Goal | How it is solved |
|------|------------------|
| Reuse at any company | Pure Terraform; clear placeholders |
| Modular | Small focused modules under `modules/` |
| Multi-owner | Independent **stacks** under `live/<env>/<stack>/`, each with its own state |
| Split state (S3 or GCS) | Every stack has its own backend key/prefix |
| Least privilege | Per-stack OAuth scopes |
| Safe cross-references | `terraform_remote_state` (read-only) between stacks |

---

## Architecture

Stacks: **identity** (groups, group rules, authenticators, network), **apps** (OAuth/SAML), **policies**, **authz**, **governance** (labels, admin roles, event hooks).

See [docs/OWNERSHIP.md](docs/OWNERSHIP.md), [docs/AUTH.md](docs/AUTH.md), [docs/IMPORT.md](docs/IMPORT.md), [docs/CI_GITHUB.md](docs/CI_GITHUB.md), [docs/CI_AWS.md](docs/CI_AWS.md), [docs/APP_TRACKING.md](docs/APP_TRACKING.md).

## Quick start

```bash
cd live/dev/identity
cp backend.hcl.example backend.hcl
cp terraform.tfvars.example terraform.tfvars
export OKTA_API_CLIENT_ID="0oa..."
export OKTA_API_PRIVATE_KEY_ID="kid-..."
export OKTA_API_PRIVATE_KEY="$(cat /path/to/private.pem)"
terraform init -backend-config=backend.hcl
terraform plan
```

Or: `make init ENV=dev STACK=identity`

## License

MIT — see [LICENSE](LICENSE).
