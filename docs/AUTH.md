# Authentication: OIDC private-key JWT only (no API tokens)

This template does **not** use Okta API tokens (SSWS).
All Terraform access is via an Okta OAuth 2.0 / OIDC API Services application using client ID + private key (private_key_jwt).

See the full guide in the repository docs after complete sync, or the local `docs/AUTH.md` in the project folder.

Required provider fields: `org_name`, `base_url`, `client_id`, `private_key`, `private_key_id`, `scopes`.
