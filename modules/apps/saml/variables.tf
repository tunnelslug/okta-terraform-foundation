variable "apps" {
  description = "List of SAML applications to create"
  type = list(object({
    label                      = string
    status                     = optional(string, "ACTIVE")
    preconfigured_app          = optional(string)
    sso_url                    = optional(string)
    recipient                  = optional(string)
    destination                = optional(string)
    audience                   = optional(string)
    subject_name_id_template   = optional(string, "$${user.userName}")
    subject_name_id_format     = optional(string, "urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified")
    response_signed            = optional(bool, true)
    assertion_signed           = optional(bool, true)
    signature_algorithm        = optional(string, "RSA_SHA256")
    digest_algorithm           = optional(string, "SHA256")
    honor_force_authn          = optional(bool, true)
    authn_context_class_ref    = optional(string, "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport")
    sp_issuer                  = optional(string)
    acs_endpoints              = optional(list(string))
    attribute_statements       = optional(list(any))
    hide_web                   = optional(bool, false)
    hide_ios                   = optional(bool, false)
    user_name_template         = optional(string)
    user_name_template_type    = optional(string, "BUILT_IN")
    accessibility_self_service = optional(bool, false)
    auto_submit_toolbar        = optional(bool, false)
    authentication_policy_id   = optional(string)
    inline_hook_id             = optional(string)
    group_ids                  = optional(list(string))
  }))
  default = []
}
