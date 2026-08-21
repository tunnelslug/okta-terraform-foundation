variable "okta_org_name" {
  type = string
}

variable "okta_base_url" {
  type    = string
  default = "okta.com"
}

variable "okta_client_id" {
  type      = string
  sensitive = true
}

variable "okta_private_key" {
  type      = string
  sensitive = true
}

variable "okta_private_key_id" {
  type = string
}

variable "okta_scopes" {
  type = list(string)
  default = [
    "okta.groups.manage",
    "okta.groups.read",
    "okta.users.manage",
    "okta.users.read",
    "okta.userSchemas.manage",
    "okta.authenticators.manage",
    "okta.authenticators.read",
    "okta.networkZones.manage",
  ]
}

variable "environment" {
  type    = string
  default = "prod"
}
