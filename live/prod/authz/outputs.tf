output "auth_server_ids" {
  value = module.auth_servers.auth_server_ids
}

output "auth_server_issuers" {
  value = module.auth_servers.auth_server_issuers
}

output "trusted_origin_ids" {
  value = module.trusted_origins.origin_ids
}

output "environment" {
  value = var.environment
}
