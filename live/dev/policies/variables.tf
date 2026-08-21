variable "okta_org_name" { type = string }
variable "okta_base_url" { type = string; default = "oktapreview.com" }
variable "okta_client_id" { type = string; sensitive = true }
variable "okta_private_key" { type = string; sensitive = true }
variable "okta_private_key_id" { type = string }
variable "okta_scopes" {
  type = list(string)
  default = ["okta.policies.manage", "okta.policies.read", "okta.groups.read"]
}
variable "environment" { type = string; default = "dev" }
