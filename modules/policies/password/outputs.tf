output "policy_ids" {
  value = { for k, p in okta_policy_password.this : k => p.id }
}
