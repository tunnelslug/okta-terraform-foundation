output "policy_ids" {
  description = "Map of MFA policy name to ID"
  value       = { for k, p in okta_policy_mfa.this : k => p.id }
}

output "policies" {
  description = "Full MFA policy objects"
  value       = okta_policy_mfa.this
}
