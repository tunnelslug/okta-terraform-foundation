resource "okta_resource_set" "this" {
  for_each = { for r in var.resource_sets : r.label => r }

  label       = each.value.label
  description = lookup(each.value, "description", null)
  resources   = lookup(each.value, "resources", null)
  resources_orn = lookup(each.value, "resources_orn", null)
}

resource "okta_admin_role_custom" "this" {
  for_each = { for r in var.custom_roles : r.label => r }

  label       = each.value.label
  description = lookup(each.value, "description", null)
  permissions = each.value.permissions
}

resource "okta_admin_role_custom_assignments" "this" {
  for_each = { for a in var.assignments : "${a.role_label}-${a.resource_set_label}" => a }

  role_id         = okta_admin_role_custom.this[each.value.role_label].id
  resource_set_id = okta_resource_set.this[each.value.resource_set_label].id
  members         = each.value.members
}
