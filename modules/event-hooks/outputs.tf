output "event_hook_ids" {
  description = "Map of event hook name to ID"
  value       = { for k, h in okta_event_hook.this : k => h.id }
}

output "log_stream_ids" {
  description = "Map of log stream name to ID"
  value       = { for k, s in okta_log_stream.this : k => s.id }
}
