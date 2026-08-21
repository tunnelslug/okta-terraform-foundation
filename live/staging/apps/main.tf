############################################################
# STACK: apps
# Owner: App platform / product IAM teams
# State: isolated (okta/<env>/apps/terraform.tfstate)
#
# Owns: OAuth/OIDC apps, SAML apps, app↔group assignments
# Reads: group_ids (identity), app_signon_policy_ids (policies)
############################################################

module "oauth_apps" {
  source = "../../../modules/apps/oauth"

  apps = [
    {
      label                      = "Internal-Dashboard"
      type                       = "web"
      grant_types                = ["authorization_code", "refresh_token"]
      redirect_uris              = ["https://dashboard.dev.example.com/callback"]
      post_logout_redirect_uris  = ["https://dashboard.dev.example.com"]
      response_types             = ["code"]
      token_endpoint_auth_method = "client_secret_basic"
      pkce_required              = true
      authentication_policy_id   = try(local.app_signon_policy_ids["Default-App-SignOn"], null)
      group_ids = [
        local.group_ids["Engineering"],
        local.group_ids["Security-Admins"],
      ]
    },
    {
      label                      = "Mobile-App"
      type                       = "native"
      grant_types                = ["authorization_code", "refresh_token"]
      redirect_uris              = ["com.example.app:/callback"]
      response_types             = ["code"]
      token_endpoint_auth_method = "none"
      pkce_required              = true
      authentication_policy_id   = try(local.app_signon_policy_ids["Default-App-SignOn"], null)
      group_ids                  = [local.group_ids["Everyone-Managed"]]
    },
    {
      label                      = "Backend-Service"
      type                       = "service"
      grant_types                = ["client_credentials"]
      token_endpoint_auth_method = "client_secret_basic"
    },
  ]
}

# Example SAML app – uncomment and customize when needed
# module "saml_apps" {
#   source = "../../../modules/apps/saml"
#   apps   = []
# }
