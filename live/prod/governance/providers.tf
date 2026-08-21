# -----------------------------------------------------------------------------
# AUTHENTICATION POLICY (non-negotiable for this template)
#
# This stack authenticates to Okta ONLY via an OAuth 2.0 / OIDC API Services
# application using private_key_jwt (client_id + private_key + private_key_id).
#
# DO NOT add api_token / OKTA_API_TOKEN. SSWS API tokens are forbidden here.
# See docs/AUTH.md for setup, scopes, and key rotation.
# -----------------------------------------------------------------------------

provider "okta" {
  org_name       = var.okta_org_name
  base_url       = var.okta_base_url
  client_id      = var.okta_client_id
  private_key    = var.okta_private_key
  private_key_id = var.okta_private_key_id
  scopes         = var.okta_scopes

  # api_token is intentionally omitted and must never be added.
}
