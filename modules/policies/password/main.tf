resource "okta_policy_password" "this" {
  for_each = { for p in var.policies : p.name => p }

  name            = each.value.name
  status          = lookup(each.value, "status", "ACTIVE")
  description     = lookup(each.value, "description", null)
  priority        = each.value.priority
  groups_included = each.value.groups_included

  password_min_length      = lookup(each.value, "password_min_length", 12)
  password_min_lowercase   = lookup(each.value, "password_min_lowercase", 1)
  password_min_uppercase   = lookup(each.value, "password_min_uppercase", 1)
  password_min_number      = lookup(each.value, "password_min_number", 1)
  password_min_symbol      = lookup(each.value, "password_min_symbol", 0)
  password_exclude_username = lookup(each.value, "password_exclude_username", true)
  password_history_count   = lookup(each.value, "password_history_count", 4)
  password_max_age_days    = lookup(each.value, "password_max_age_days", 90)
  password_min_age_minutes = lookup(each.value, "password_min_age_minutes", 0)
  password_expire_warn_days = lookup(each.value, "password_expire_warn_days", 5)
}

resource "okta_policy_rule_password" "this" {
  for_each = { for r in var.rules : "${r.policy_name}-${r.name}" => r }

  policy_id = okta_policy_password.this[each.value.policy_name].id
  name      = each.value.name
  status    = lookup(each.value, "status", "ACTIVE")
  priority  = each.value.priority
}
