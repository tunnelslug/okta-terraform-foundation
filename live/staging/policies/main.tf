############################################################
# STACK: policies
# Owner: Security / IAM platform
# State: isolated (okta/<env>/policies/terraform.tfstate)
#
# Owns: global session policies, app sign-on policies,
#       MFA enrollment policies, password policies
############################################################

module "signon" {
  source = "../../../modules/policies/signon"

  global_session_policies = [
    {
      name            = "Default-Global-Session"
      priority        = 1
      groups_included = [local.group_ids["Everyone-Managed"]]
      description     = "Baseline session policy"
    },
    {
      name            = "Passwordless-Global-Session"
      priority        = 2
      groups_included = [local.group_ids["Passwordless-Users"]]
      description     = "Session policy for passwordless cohort"
    },
  ]

  global_session_rules = [
    {
      policy_name        = "Default-Global-Session"
      name               = "Allow-Anywhere"
      priority           = 1
      access             = "ALLOW"
      network_connection = "ANYWHERE"
      mfa_required       = true
      session_idle       = 120
      session_lifetime   = 480
    },
  ]

  app_signon_policies = [
    {
      name        = "Default-App-SignOn"
      description = "Standard 2FA for most applications"
    },
    {
      name        = "High-Security-App-SignOn"
      description = "Strict policy for sensitive applications"
    },
    {
      name        = "Passwordless-App-SignOn"
      description = "1FA / passwordless policy"
    },
  ]

  app_signon_rules = [
    {
      policy_name                 = "Default-App-SignOn"
      name                        = "Require-2FA"
      priority                    = 1
      access                      = "ALLOW"
      factor_mode                 = "2FA"
      re_authentication_frequency = "PT8H"
      groups_included             = [local.group_ids["Engineering"], local.group_ids["Everyone-Managed"]]
    },
    {
      policy_name                 = "High-Security-App-SignOn"
      name                        = "Require-Phishing-Resistant"
      priority                    = 1
      access                      = "ALLOW"
      factor_mode                 = "2FA"
      re_authentication_frequency = "PT1H"
      groups_included             = [local.group_ids["Security-Admins"]]
    },
    {
      policy_name                 = "Passwordless-App-SignOn"
      name                        = "Passwordless-Allow"
      priority                    = 1
      access                      = "ALLOW"
      factor_mode                 = "1FA"
      re_authentication_frequency = "PT12H"
      groups_included             = [local.group_ids["Passwordless-Users"]]
    },
  ]
}

module "mfa" {
  source = "../../../modules/policies/mfa"

  policies = [
    {
      name            = "Default-MFA-Enrollment"
      priority        = 1
      groups_included = [local.group_ids["Everyone-Managed"]]
      is_oie          = true
      okta_verify     = { enroll = "REQUIRED" }
      webauthn        = { enroll = "OPTIONAL" }
      email           = { enroll = "OPTIONAL" }
    },
    {
      name            = "High-Security-MFA"
      priority        = 2
      groups_included = [local.group_ids["Security-Admins"]]
      is_oie          = true
      okta_verify     = { enroll = "REQUIRED" }
      webauthn        = { enroll = "REQUIRED" }
    },
  ]

  rules = [
    {
      policy_name = "Default-MFA-Enrollment"
      name        = "Enroll-Anywhere"
      priority    = 1
      enroll      = "CHALLENGE"
    },
  ]
}

module "password" {
  source = "../../../modules/policies/password"

  policies = [
    {
      name            = "Default-Password-Policy"
      priority        = 1
      groups_included = [local.group_ids["Everyone-Managed"]]
      password_min_length = 14
      password_history_count = 24
    },
  ]

  rules = [
    {
      policy_name = "Default-Password-Policy"
      name        = "Allow-Password-Ops"
      priority    = 1
    },
  ]
}
