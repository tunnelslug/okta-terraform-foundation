variable "apps" {
  description = "List of OAuth/OIDC applications to create"
  type = list(object({
    label                          = string
    type                           = string
    status                         = optional(string, "ACTIVE")
    grant_types                    = list(string)
    redirect_uris                  = optional(list(string))
    post_logout_redirect_uris      = optional(list(string))
    response_types                 = optional(list(string), ["code"])
    token_endpoint_auth_method     = optional(string, "client_secret_basic")
    pkce_required                  = optional(bool)
    login_uri                      = optional(string)
    logo                           = optional(string)
    admin_note                     = optional(string)
    enduser_note                   = optional(string)
    omit_secret                    = optional(bool, false)
    client_basic_secret            = optional(string)
    client_id                      = optional(string)
    client_uri                     = optional(string)
    policy_uri                     = optional(string)
    tos_uri                        = optional(string)
    consent_method                 = optional(string, "REQUIRED")
    issuer_mode                    = optional(string, "ORG_URL")
    wildcard_redirect              = optional(string, "DISABLED")
    login_mode                     = optional(string, "DISABLED")
    login_scopes                   = optional(list(string))
    accessibility_error_redirect_url = optional(string)
    accessibility_login_redirect_url = optional(string)
    accessibility_self_service     = optional(bool, false)
    auto_submit_toolbar            = optional(bool, false)
    hide_web                       = optional(bool, false)
    hide_ios                       = optional(bool, false)
    user_name_template             = optional(string)
    user_name_template_type        = optional(string, "BUILT_IN")
    user_name_template_suffix      = optional(string)
    user_name_template_push_status = optional(string)
    authentication_policy_id       = optional(string)
    group_ids                      = optional(list(string))
    groups_claim = optional(object({
      type  = string
      name  = string
      value = string
    }))
    jwks = optional(list(object({
      kty = string
      kid = string
      e   = optional(string)
      n   = optional(string)
      x   = optional(string)
      y   = optional(string)
    })))
  }))
  default = []
}
