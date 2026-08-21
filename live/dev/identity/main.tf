############################################################
# STACK: identity
############################################################

module "groups" {
  source = "../../../modules/groups"

  groups = [
    { name = "Engineering", description = "All engineering employees" },
    { name = "Security-Admins", description = "Security team with elevated privileges" },
    { name = "Contractors", description = "External contractors with limited access" },
    { name = "Passwordless-Users", description = "Users enrolled in passwordless authentication" },
    { name = "Everyone-Managed", description = "Managed cohort used by baseline policies" },
  ]

  group_rules = [
    {
      name              = "Engineering-by-Department"
      group_assignments = ["Engineering"]
      expression_value  = "user.department==\"Engineering\""
    },
  ]
}

module "authenticators" {
  source = "../../../modules/authenticators"
  authenticators = [
    { name = "Okta Verify", key = "okta_verify", status = "ACTIVE", settings = jsonencode({ userVerification = "PREFERRED" }) },
    { name = "WebAuthn", key = "webauthn", status = "ACTIVE" },
    { name = "Email", key = "okta_email", status = "ACTIVE", settings = jsonencode({ allowedFor = "any" }) },
    { name = "Phone", key = "phone_number", status = "ACTIVE" },
  ]
}

module "network" {
  source = "../../../modules/network"
  zones = [
    {
      name     = "Corporate-HQ"
      type     = "IP"
      gateways = ["203.0.113.0/24", "198.51.100.0/24"]
      usage    = "POLICY"
    },
  ]
}
