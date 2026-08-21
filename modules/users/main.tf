# Prefer managing users via SCIM / HRIS. Use this module only for break-glass or tightly-controlled service accounts.

resource "okta_user" "this" {
  for_each = { for u in var.users : u.login => u }

  first_name                = each.value.first_name
  last_name                 = each.value.last_name
  login                     = each.value.login
  email                     = each.value.email
  status                    = lookup(each.value, "status", "ACTIVE")
  password                  = lookup(each.value, "password", null)
  custom_profile_attributes = lookup(each.value, "custom_profile_attributes", null)
  expire_password_on_create = lookup(each.value, "expire_password_on_create", false)
  skip_roles                = lookup(each.value, "skip_roles", true)
}

resource "okta_user_group_memberships" "this" {
  for_each = { for u in var.users : u.login => u if lookup(u, "group_ids", null) != null }

  user_id = okta_user.this[each.key].id
  groups  = each.value.group_ids
}
