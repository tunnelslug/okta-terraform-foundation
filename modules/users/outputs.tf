output "user_ids" {
  description = "Map of login to user ID"
  value       = { for k, u in okta_user.this : k => u.id }
}
