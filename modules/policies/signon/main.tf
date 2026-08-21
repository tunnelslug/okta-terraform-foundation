resource "okta_policy_signon" "global" {
  for_each = { for p in var.global_policies : p.name => p }

  name            = each.value.name
  status          = lookup(each.value, "status", "ACTIVE")
  description     = lookup(each.value, "description", null)
  priority        = each.value.priority
  groups_included = each.value.groups_included
}

resource "okta_policy_rule_signon" "global" {
  for_each = { for r in var.global_rules : "${r.policy_name}-${r.name}" => r }

  policy_id          = okta_policy_signon.global[each.value.policy_name].id
  name               = each.value.name
  status             = lookup(each.value, "status", "ACTIVE")
  priority           = each.value.priority
  access             = lookup(each.value, "access", "ALLOW")
  network_connection = lookup(each.value, "network_connection", "ANYWHERE")
  network_includes   = lookup(each.value, "network_includes", null)
  network_excludes   = lookup(each.value, "network_excludes", null)
  mfa_required       = lookup(each.value, "mfa_required", false)
  mfa_prompt         = lookup(each.value, "mfa_prompt", null)
  session_idle       = lookup(each.value, "session_idle", null)
  session_lifetime   = lookup(each.value, "session_lifetime", null)
  primary_factor     = lookup(each.value, "primary_factor", null)
}

resource "okta_app_signon_policy" "this" {
  for_each    = { for p in var.app_policies : p.name => p }
  name        = each.value.name
  description = lookup(each.value, "description", null)
}

resource "okta_app_signon_policy_rule" "this" {
  for_each = { for r in var.app_rules : "${r.policy_name}-${r.name}" => r }

  policy_id = okta_app_signon_policy.this[each.value.policy_name].id
  name      = each.value.name
  status    = lookup(each.value, "status", "ACTIVE")
  priority  = each.value.priority
  access    = lookup(each.value, "access", "ALLOW")
}
