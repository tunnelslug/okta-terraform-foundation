resource "okta_policy_mfa" "this" {
  for_each = { for p in var.policies : p.name => p }

  name            = each.value.name
  status          = lookup(each.value, "status", "ACTIVE")
  description     = lookup(each.value, "description", null)
  priority        = each.value.priority
  groups_included = each.value.groups_included
  is_oie          = lookup(each.value, "is_oie", true)

  okta_password   = lookup(each.value, "okta_password", null)
  okta_otp        = lookup(each.value, "okta_otp", null)
  okta_sms        = lookup(each.value, "okta_sms", null)
  okta_call       = lookup(each.value, "okta_call", null)
  okta_question   = lookup(each.value, "okta_question", null)
  okta_push       = lookup(each.value, "okta_push", null)
  okta_email      = lookup(each.value, "okta_email", null)
  google_otp      = lookup(each.value, "google_otp", null)
  rsa_token       = lookup(each.value, "rsa_token", null)
  symantec_vip    = lookup(each.value, "symantec_vip", null)
  yubikey_token   = lookup(each.value, "yubikey_token", null)
  duo             = lookup(each.value, "duo", null)
  hotp            = lookup(each.value, "hotp", null)
  fido_webauthn   = lookup(each.value, "fido_webauthn", null)
  fido_u2f        = lookup(each.value, "fido_u2f", null)

  okta_verify     = lookup(each.value, "okta_verify", null)
  webauthn        = lookup(each.value, "webauthn", null)
  phone_number    = lookup(each.value, "phone_number", null)
  email           = lookup(each.value, "email", null)
  security_question = lookup(each.value, "security_question", null)
  custom_otp      = lookup(each.value, "custom_otp", null)
  custom_app      = lookup(each.value, "custom_app", null)
  external_idp    = lookup(each.value, "external_idp", null)
}

resource "okta_policy_rule_mfa" "this" {
  for_each = { for r in var.rules : "${r.policy_name}-${r.name}" => r }

  policy_id          = okta_policy_mfa.this[each.value.policy_name].id
  name               = each.value.name
  status             = lookup(each.value, "status", "ACTIVE")
  priority           = each.value.priority
  enroll             = lookup(each.value, "enroll", "CHALLENGE")
  network_connection = lookup(each.value, "network_connection", "ANYWHERE")
  network_includes   = lookup(each.value, "network_includes", null)
  network_excludes   = lookup(each.value, "network_excludes", null)
  users_excluded     = lookup(each.value, "users_excluded", null)

  depends_on = [okta_policy_mfa.this]
}
