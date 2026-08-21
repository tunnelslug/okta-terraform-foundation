output "authenticator_ids" {
  description = "Map of authenticator name to ID"
  value       = { for k, a in okta_authenticator.this : k => a.id }
}
