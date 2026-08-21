output "group_ids" {
  description = "Map of group name → group ID"
  value       = { for k, g in okta_group.this : k => g.id }
}

output "group_names" {
  description = "List of created group names"
  value       = [for g in okta_group.this : g.name]
}

output "groups" {
  description = "Full group objects"
  value       = okta_group.this
}
