output "resource_set_ids" {
  description = "Map of resource set label → ID"
  value       = { for k, r in okta_resource_set.this : k => r.id }
}

output "custom_role_ids" {
  description = "Map of custom role label → ID"
  value       = { for k, r in okta_admin_role_custom.this : k => r.id }
}
