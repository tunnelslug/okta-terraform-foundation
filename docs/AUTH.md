# Authentication: OIDC private-key JWT only (no API tokens)

This template **does not use Okta API tokens** (SSWS).  
All Terraform access is via an **Okta OAuth 2.0 / OIDC API Services application** using a **client ID + private key** (private_key_jwt).

Why this is required:

| API token (SSWS) | OIDC service app (this template) |
|------------------|----------------------------------|
| Long-lived secret, hard to scope | Short-lived tokens, scope-bound |
| Often tied to a human admin | Machine identity, no user session |
| Broad org access if leaked | Least-privilege scopes per stack |
| Difficult to rotate safely | Rotate key without changing client_id |
| No standard audit of “which automation” | Clear service principal in logs |

---

## 1. Create the Okta API Services app

In the Okta Admin Console:

1. **Applications → Applications → Create App Integration**
2. Choose **API Services**
3. Name it e.g. `terraform-okta-platform` (or one app **per stack** for stronger isolation)
4. After creation:
   - Note the **Client ID**
   - Under **Client Credentials**, choose **Public key / Private key**
   - Generate a key pair **or** upload your own public key
   - Note the **Key ID (kid)**
   - Store the **private key PEM** in a secrets manager (never in git)

5. **Admin roles** (API Services app): assign the minimum admin roles needed  
   (or use custom roles + resource sets from the `governance` stack).

6. **Okta API Scopes** tab: grant only what that app’s stacks need  
   (see scope matrix below).

---

## 2. Provider configuration (already wired)

Every stack uses:

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

There is **no** `api_token` argument anywhere in this template.

### Credentials via environment (recommended)

```bash
export OKTA_ORG_NAME="dev-123456"
export OKTA_BASE_URL="oktapreview.com"
export OKTA_API_CLIENT_ID="0oa..."
export OKTA_API_PRIVATE_KEY_ID="kid-..."
export OKTA_API_PRIVATE_KEY="$(cat /path/to/private.pem)"
```

Or pass via `terraform.tfvars` (except the private key — prefer env / secret store):

```hcl
okta_org_name       = "dev-123456"
okta_base_url       = "oktapreview.com"
okta_client_id      = "0oa..."
okta_private_key_id = "kid-..."
# okta_private_key  → set from CI secret / env only
```

---

## 3. Recommended scope matrix (per stack)

| Stack | Scopes |
|-------|--------|
| **identity** | `okta.groups.manage`, `okta.groups.read`, `okta.users.manage`, `okta.users.read`, `okta.userSchemas.manage`, `okta.authenticators.manage`, `okta.authenticators.read`, `okta.networkZones.manage` |
| **apps** | `okta.apps.manage`, `okta.apps.read`, `okta.groups.read` |
| **policies** | `okta.policies.manage`, `okta.policies.read`, `okta.groups.read`, `okta.apps.read` |
| **authz** | `okta.authorizationServers.manage`, `okta.authorizationServers.read`, `okta.trustedOrigins.manage`, `okta.groups.read`, `okta.apps.read` |
| **governance** | `okta.governance.labels.manage`, `okta.governance.labels.read`, `okta.roles.manage`, `okta.roles.read`, `okta.eventHooks.manage`, `okta.eventHooks.read`, `okta.logStreams.manage`, `okta.logStreams.read` |

**Best practice:** one API Services app **per stack** (or per team), each with only that row’s scopes.

---

## 4. Generate a key pair (local)

```bash
openssl genrsa -out okta-tf-private.pem 2048
openssl rsa -in okta-tf-private.pem -pubout -out okta-tf-public.pem
```

Or: `make gen-oidc-key`

---

## 5. What is explicitly forbidden

- `provider "okta" { api_token = "..." }`
- Env var `OKTA_API_TOKEN` for this template’s workflows
- Long-lived SSWS tokens in CI variables

If a future contributor adds `api_token`, reject the PR. CI should fail if `api_token` appears under `live/` or `modules/`.

---

## 6. Rotation

1. Generate a new key pair.
2. Add the new public key on the Okta app (you can have multiple keys).
3. Update the secret (`OKTA_API_PRIVATE_KEY` + kid) in CI / secret store.
4. Remove the old public key from Okta after verifying applies succeed.

No need to recreate the app or change `client_id` for routine rotation.
