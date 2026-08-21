resource "okta_group" "this" {
  for_each = { for g in var.groups : g.name => g }

  name        = each.value.name
  description = lookup(each.value, "description", null)

  # Optional custom profile attributes
  custom_profile_attributes = lookup(each.value, "custom_profile_attributes", null)
}

resource "okta_group_rule" "this" {
  for_each = { for r in var.group_rules : r.name => r }

  name   = each.value.name
  status = lookup(each.value, "status", "ACTIVE")

  group_assignments = [
    for g in each.value.group_assignments : okta_group.this[g].id
  ]

  expression_type  = "urn:okta:expression:1.0"
  expression_value = each.value.expression_value

  # Optional: users excluded from the rule
  users_excluded = lookup(each.value, "users_excluded", null)
}
