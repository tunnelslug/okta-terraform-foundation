# Authenticate ONLY via OAuth 2.0 / OIDC API Services app + private_key_jwt.
# DO NOT use api_token. See docs/AUTH.md.

provider "okta" {
  org_name       = var.okta_org_name
  base_url       = var.okta_base_url
  client_id      = var.okta_client_id
  private_key    = var.okta_private_key
  private_key_id = var.okta_private_key_id
  scopes         = var.okta_scopes
}
