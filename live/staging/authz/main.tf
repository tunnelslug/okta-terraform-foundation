############################################################
# STACK: authz
# Owner: API / platform security
# State: isolated (okta/<env>/authz/terraform.tfstate)
#
# Owns: custom authorization servers, scopes, claims,
#       auth server policies/rules, trusted origins
############################################################

module "auth_servers" {
  source = "../../../modules/auth-servers"

  auth_servers = [
    {
      name        = "api-authorization-server"
      description = "Custom auth server for internal APIs"
      audiences   = ["api://default"]
      issuer_mode = "ORG_URL"
    },
  ]

  scopes = [
    {
      auth_server_name = "api-authorization-server"
      name             = "api:read"
      description      = "Read access to APIs"
      consent          = "IMPLICIT"
    },
    {
      auth_server_name = "api-authorization-server"
      name             = "api:write"
      description      = "Write access to APIs"
      consent          = "REQUIRED"
    },
  ]

  claims = [
    {
      auth_server_name        = "api-authorization-server"
      name                    = "groups"
      value_type              = "GROUPS"
      claim_type              = "RESOURCE"
      group_filter_type       = "REGEX"
      value                   = ".*"
      always_include_in_token = true
    },
    {
      auth_server_name        = "api-authorization-server"
      name                    = "email"
      value_type              = "EXPRESSION"
      value                   = "user.email"
      claim_type              = "RESOURCE"
      always_include_in_token = true
    },
  ]

  policies = [
    {
      auth_server_name = "api-authorization-server"
      name             = "Default-Policy"
      priority         = 1
      client_whitelist = ["ALL_CLIENTS"]
    },
  ]

  rules = [
    {
      auth_server_name     = "api-authorization-server"
      policy_name          = "Default-Policy"
      name                 = "Allow-Engineering"
      priority             = 1
      grant_type_whitelist = ["authorization_code", "client_credentials"]
      scope_whitelist      = ["api:read", "api:write", "openid", "profile", "email"]
      group_whitelist = [
        local.group_ids["Engineering"],
        local.group_ids["Security-Admins"],
      ]
    },
  ]
}

module "trusted_origins" {
  source = "../../../modules/trusted-origins"

  origins = [
    {
      name   = "Dashboard-Dev"
      origin = "https://dashboard.dev.example.com"
      scopes = ["CORS", "REDIRECT"]
    },
    {
      name   = "Local-Dev"
      origin = "http://localhost:3000"
      scopes = ["CORS", "REDIRECT"]
    },
  ]
}
