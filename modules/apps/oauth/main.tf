resource "okta_app_oauth" "this" {
  for_each = { for a in var.apps : a.label => a }

  label                       = each.value.label
  type                        = each.value.type
  status                      = lookup(each.value, "status", "ACTIVE")
  grant_types                 = each.value.grant_types
  redirect_uris               = lookup(each.value, "redirect_uris", null)
  post_logout_redirect_uris   = lookup(each.value, "post_logout_redirect_uris", null)
  response_types              = lookup(each.value, "response_types", ["code"])
  token_endpoint_auth_method  = lookup(each.value, "token_endpoint_auth_method", "client_secret_basic")
  pkce_required               = lookup(each.value, "pkce_required", null)
  login_uri                   = lookup(each.value, "login_uri", null)
  logo                        = lookup(each.value, "logo", null)
  admin_note                  = lookup(each.value, "admin_note", null)
  enduser_note                = lookup(each.value, "enduser_note", null)
  omit_secret                 = lookup(each.value, "omit_secret", false)
  client_basic_secret         = lookup(each.value, "client_basic_secret", null)
  client_id                   = lookup(each.value, "client_id", null)
  client_uri                  = lookup(each.value, "client_uri", null)
  policy_uri                  = lookup(each.value, "policy_uri", null)
  tos_uri                     = lookup(each.value, "tos_uri", null)
  consent_method              = lookup(each.value, "consent_method", "REQUIRED")
  issuer_mode                 = lookup(each.value, "issuer_mode", "ORG_URL")
  wildcard_redirect           = lookup(each.value, "wildcard_redirect", "DISABLED")
  login_mode                  = lookup(each.value, "login_mode", "DISABLED")
  login_scopes                = lookup(each.value, "login_scopes", null)
  accessibility_error_redirect_url = lookup(each.value, "accessibility_error_redirect_url", null)
  accessibility_login_redirect_url = lookup(each.value, "accessibility_login_redirect_url", null)
  accessibility_self_service  = lookup(each.value, "accessibility_self_service", false)
  auto_submit_toolbar         = lookup(each.value, "auto_submit_toolbar", false)
  hide_web                    = lookup(each.value, "hide_web", false)
  hide_ios                    = lookup(each.value, "hide_ios", false)
  user_name_template          = lookup(each.value, "user_name_template", null)
  user_name_template_type     = lookup(each.value, "user_name_template_type", "BUILT_IN")
  user_name_template_suffix   = lookup(each.value, "user_name_template_suffix", null)
  user_name_template_push_status = lookup(each.value, "user_name_template_push_status", null)
  authentication_policy = lookup(each.value, "authentication_policy_id", null)

  dynamic "groups_claim" {
    for_each = lookup(each.value, "groups_claim", null) != null ? [each.value.groups_claim] : []
    content {
      type  = groups_claim.value.type
      name  = groups_claim.value.name
      value = groups_claim.value.value
    }
  }

  dynamic "jwks" {
    for_each = lookup(each.value, "jwks", null) != null ? each.value.jwks : []
    content {
      kty = jwks.value.kty
      kid = jwks.value.kid
      e   = lookup(jwks.value, "e", null)
      n   = lookup(jwks.value, "n", null)
      x   = lookup(jwks.value, "x", null)
      y   = lookup(jwks.value, "y", null)
    }
  }
}

resource "okta_app_group_assignments" "this" {
  for_each = { for a in var.apps : a.label => a if lookup(a, "group_ids", null) != null }
  app_id = okta_app_oauth.this[each.key].id
  dynamic "group" {
    for_each = each.value.group_ids
    content {
      id       = group.value
      priority = group.key + 1
    }
  }
}
