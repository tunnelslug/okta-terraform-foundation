output "oauth_app_ids" {
  value = module.oauth_apps.app_ids
}

output "oauth_client_ids" {
  value     = module.oauth_apps.client_ids
  sensitive = true
}

output "environment" {
  value = var.environment
}
