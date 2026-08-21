output "label_ids" {
  value = module.labels.label_ids
}

output "resource_set_ids" {
  value = module.admin_roles.resource_set_ids
}

output "custom_role_ids" {
  value = module.admin_roles.custom_role_ids
}

output "environment" {
  value = var.environment
}

output "event_hook_ids" {
  value = module.event_hooks.event_hook_ids
}

output "log_stream_ids" {
  value = module.event_hooks.log_stream_ids
}
