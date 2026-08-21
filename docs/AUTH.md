# Authentication: OIDC private-key JWT only (no API tokens)

This template authenticates to Okta **only** with an OAuth 2.0 / OIDC **API Services** app:

- `client_id`
- `private_key` (PEM)
- `private_key_id` (kid)
- `scopes` (least privilege per stack)

**Do not** use `api_token` / SSWS tokens.

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

Generate keys: `make gen-oidc-key`  
Guard: `make check-no-api-token`

Store private keys in Secrets Manager / Vault. Never commit PEMs.
