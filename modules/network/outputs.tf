output "zone_ids" {
  description = "Map of zone name to ID"
  value       = { for k, z in okta_network_zone.this : k => z.id }
}
