output "app_ids" {
  description = "Map of app label to app ID"
  value       = { for k, a in okta_app_oauth.this : k => a.id }
}

output "client_ids" {
  description = "Map of app label to client_id"
  value       = { for k, a in okta_app_oauth.this : k => a.client_id }
}

output "apps" {
  description = "Full application objects"
  value       = okta_app_oauth.this
  sensitive   = true
}
