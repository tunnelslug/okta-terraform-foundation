resource "okta_authenticator" "this" {
  for_each = { for a in var.authenticators : a.name => a }

  name               = each.value.name
  key                = each.value.key
  status             = lookup(each.value, "status", "ACTIVE")
  settings           = lookup(each.value, "settings", null)
  provider_json      = lookup(each.value, "provider_json", null)
  agree_to_terms     = lookup(each.value, "agree_to_terms", null)
  legacy_ignore_name = lookup(each.value, "legacy_ignore_name", null)
}
