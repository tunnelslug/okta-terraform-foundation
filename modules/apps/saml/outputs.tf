output "app_ids" {
  description = "Map of app label to app ID"
  value       = { for k, a in okta_app_saml.this : k => a.id }
}

output "apps" {
  description = "Full SAML application objects"
  value       = okta_app_saml.this
}
