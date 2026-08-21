output "global_policy_ids" {
  value = { for k, p in okta_policy_signon.global : k => p.id }
}
output "app_policy_ids" {
  value = { for k, p in okta_app_signon_policy.this : k => p.id }
}
