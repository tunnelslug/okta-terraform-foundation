resource "okta_auth_server" "this" {
  for_each = { for s in var.auth_servers : s.name => s }
  name        = each.value.name
  description = lookup(each.value, "description", null)
  audiences   = each.value.audiences
  issuer_mode = lookup(each.value, "issuer_mode", "ORG_URL")
  status      = lookup(each.value, "status", "ACTIVE")
}

resource "okta_auth_server_scope" "this" {
  for_each = { for s in var.scopes : "${s.auth_server_name}-${s.name}" => s }
  auth_server_id   = okta_auth_server.this[each.value.auth_server_name].id
  name             = each.value.name
  description      = lookup(each.value, "description", null)
  consent          = lookup(each.value, "consent", "IMPLICIT")
  default          = lookup(each.value, "default", false)
  metadata_publish = lookup(each.value, "metadata_publish", "ALL_CLIENTS")
  display_name     = lookup(each.value, "display_name", null)
}

resource "okta_auth_server_claim" "this" {
  for_each = { for c in var.claims : "${c.auth_server_name}-${c.name}" => c }
  auth_server_id    = okta_auth_server.this[each.value.auth_server_name].id
  name              = each.value.name
  status            = lookup(each.value, "status", "ACTIVE")
  value_type        = each.value.value_type
  value             = lookup(each.value, "value", null)
  claim_type        = lookup(each.value, "claim_type", "RESOURCE")
  always_include_in_token = lookup(each.value, "always_include_in_token", false)
  group_filter_type = lookup(each.value, "group_filter_type", null)
  scopes            = lookup(each.value, "scopes", null)
}

resource "okta_auth_server_policy" "this" {
  for_each = { for p in var.policies : "${p.auth_server_name}-${p.name}" => p }
  auth_server_id   = okta_auth_server.this[each.value.auth_server_name].id
  name             = each.value.name
  description      = lookup(each.value, "description", null)
  priority         = each.value.priority
  client_whitelist = each.value.client_whitelist
  status           = lookup(each.value, "status", "ACTIVE")
}

resource "okta_auth_server_policy_rule" "this" {
  for_each = { for r in var.rules : "${r.auth_server_name}-${r.policy_name}-${r.name}" => r }
  auth_server_id       = okta_auth_server.this[each.value.auth_server_name].id
  policy_id            = okta_auth_server_policy.this["${each.value.auth_server_name}-${each.value.policy_name}"].id
  name                 = each.value.name
  status               = lookup(each.value, "status", "ACTIVE")
  priority             = each.value.priority
  grant_type_whitelist = each.value.grant_type_whitelist
  scope_whitelist      = lookup(each.value, "scope_whitelist", ["*"])
  group_whitelist      = lookup(each.value, "group_whitelist", null)
  group_blacklist      = lookup(each.value, "group_blacklist", null)
  user_whitelist       = lookup(each.value, "user_whitelist", null)
  user_blacklist       = lookup(each.value, "user_blacklist", null)
  inline_hook_id       = lookup(each.value, "inline_hook_id", null)
  depends_on = [okta_auth_server_policy.this, okta_auth_server_scope.this]
}
