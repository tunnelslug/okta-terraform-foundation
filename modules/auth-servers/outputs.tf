output "auth_server_ids" {
  value = { for k, s in okta_auth_server.this : k => s.id }
}
output "auth_server_issuers" {
  value = { for k, s in okta_auth_server.this : k => s.issuer }
}
output "scope_ids" {
  value = { for k, s in okta_auth_server_scope.this : k => s.id }
}
output "claim_ids" {
  value = { for k, c in okta_auth_server_claim.this : k => c.id }
}
