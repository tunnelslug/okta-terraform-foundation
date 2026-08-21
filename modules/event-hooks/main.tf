############################################################
# Okta Event Hooks
############################################################

resource "okta_event_hook" "this" {
  for_each = { for h in var.hooks : h.name => h }

  name   = each.value.name
  events = each.value.events
  status = lookup(each.value, "status", "ACTIVE")

  channel = {
    type    = "HTTP"
    version = "1.0.0"
    uri     = each.value.uri
  }

  dynamic "auth" {
    for_each = lookup(each.value, "auth_type", null) != null ? [1] : []
    content {
      type  = each.value.auth_type
      key   = lookup(each.value, "auth_key", "Authorization")
      value = each.value.auth_value
    }
  }

  dynamic "headers" {
    for_each = lookup(each.value, "headers", {})
    content {
      key   = headers.key
      value = headers.value
    }
  }
}

resource "okta_log_stream" "this" {
  for_each = { for s in var.log_streams : s.name => s }

  name   = each.value.name
  type   = each.value.type
  status = lookup(each.value, "status", "ACTIVE")

  settings {
    account_id        = lookup(each.value, "account_id", null)
    region            = lookup(each.value, "region", null)
    event_source_name = lookup(each.value, "event_source_name", null)
    host              = lookup(each.value, "host", null)
    edition           = lookup(each.value, "edition", null)
    token             = lookup(each.value, "token", null)
  }
}
