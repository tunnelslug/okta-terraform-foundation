resource "okta_network_zone" "this" {
  for_each = { for z in var.zones : z.name => z }

  name     = each.value.name
  type     = each.value.type
  status   = lookup(each.value, "status", "ACTIVE")
  usage    = lookup(each.value, "usage", "POLICY")
  asns     = lookup(each.value, "asns", null)
  gateways = lookup(each.value, "gateways", null)
  proxies  = lookup(each.value, "proxies", null)
  locations = lookup(each.value, "locations", null)
  dynamic_locations = lookup(each.value, "dynamic_locations", null)
  dynamic_proxy_type = lookup(each.value, "dynamic_proxy_type", null)
  ip_service_categories_include = lookup(each.value, "ip_service_categories_include", null)
  ip_service_categories_exclude = lookup(each.value, "ip_service_categories_exclude", null)
}
