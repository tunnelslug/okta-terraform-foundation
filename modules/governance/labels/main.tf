############################################################
# Okta Identity Governance Labels
############################################################

resource "okta_label" "this" {
  for_each = { for l in var.labels : l.name => l }

  name = each.value.name

  dynamic "values" {
    for_each = each.value.values
    content {
      name = values.value.name
    }
  }
}
