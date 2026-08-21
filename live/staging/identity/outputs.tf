output "group_ids" {
  value = module.groups.group_ids
}

output "group_rule_ids" {
  value = module.groups.group_rule_ids
}

output "authenticator_ids" {
  value = module.authenticators.authenticator_ids
}

output "network_zone_ids" {
  value = module.network.zone_ids
}

output "environment" {
  value = var.environment
}
