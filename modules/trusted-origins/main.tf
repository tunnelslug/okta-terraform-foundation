resource "okta_trusted_origin" "this" {
  for_each = { for t in var.origins : t.name => t }

  name   = each.value.name
  origin = each.value.origin
  scopes = each.value.scopes
}
