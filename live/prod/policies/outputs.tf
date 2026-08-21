output "global_session_policy_ids" {
  value = module.signon.global_session_policy_ids
}

output "app_signon_policy_ids" {
  description = "Consumed by apps stack for authentication_policy"
  value       = module.signon.app_signon_policy_ids
}

output "mfa_policy_ids" {
  value = module.mfa.policy_ids
}

output "password_policy_ids" {
  value = module.password.policy_ids
}

output "environment" {
  value = var.environment
}
