output "label_ids" {
  description = "Map of label name (key) to label ID"
  value       = { for k, l in okta_label.this : k => l.id }
}

output "labels" {
  description = "Full label objects"
  value       = okta_label.this
}
