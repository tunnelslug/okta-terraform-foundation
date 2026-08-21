variable "policies" {
  description = "MFA / Authenticator Enrollment Policies"
  type = list(object({
    name            = string
    status          = optional(string, "ACTIVE")
    description     = optional(string)
    priority        = number
    groups_included = list(string)
    is_oie          = optional(bool, true)
    okta_password     = optional(map(string))
    okta_otp          = optional(map(string))
    okta_sms          = optional(map(string))
    okta_call         = optional(map(string))
    okta_question     = optional(map(string))
    okta_push         = optional(map(string))
    okta_email        = optional(map(string))
    google_otp        = optional(map(string))
    rsa_token         = optional(map(string))
    symantec_vip      = optional(map(string))
    yubikey_token     = optional(map(string))
    duo               = optional(map(string))
    hotp              = optional(map(string))
    fido_webauthn     = optional(map(string))
    fido_u2f          = optional(map(string))
    okta_verify       = optional(map(string))
    webauthn          = optional(map(string))
    phone_number      = optional(map(string))
    email             = optional(map(string))
    security_question = optional(map(string))
    custom_otp        = optional(map(string))
    custom_app        = optional(list(map(string)))
    external_idp      = optional(map(string))
  }))
  default = []
}

variable "rules" {
  description = "Rules for MFA policies"
  type = list(object({
    policy_name        = string
    name               = string
    status             = optional(string, "ACTIVE")
    priority           = number
    enroll             = optional(string, "CHALLENGE")
    network_connection = optional(string, "ANYWHERE")
    network_includes   = optional(list(string))
    network_excludes   = optional(list(string))
    users_excluded     = optional(list(string))
  }))
  default = []
}
