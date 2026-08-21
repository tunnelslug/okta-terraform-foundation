output "group_ids" {
  value = module.groups.group_ids
}

output "authenticator_ids" {
  value = module.authenticators.authenticator_ids
}

output "zone_ids" {
  value = module.network.zone_ids
}

output "environment" {
  value = var.environment
}
