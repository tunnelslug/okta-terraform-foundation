output "origin_ids" {
  description = "Map of trusted origin name to ID"
  value       = { for k, o in okta_trusted_origin.this : k => o.id }
}
