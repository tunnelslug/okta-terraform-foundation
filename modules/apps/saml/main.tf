resource "okta_app_saml" "this" {
  for_each = { for a in var.apps : a.label => a }

  label                    = each.value.label
  status                   = lookup(each.value, "status", "ACTIVE")
  preconfigured_app        = lookup(each.value, "preconfigured_app", null)
  sso_url                  = lookup(each.value, "sso_url", null)
  recipient                = lookup(each.value, "recipient", null)
  destination              = lookup(each.value, "destination", null)
  audience                 = lookup(each.value, "audience", null)
  subject_name_id_template = lookup(each.value, "subject_name_id_template", "$${user.userName}")
  subject_name_id_format   = lookup(each.value, "subject_name_id_format", "urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified")
  response_signed          = lookup(each.value, "response_signed", true)
  assertion_signed         = lookup(each.value, "assertion_signed", true)
  signature_algorithm      = lookup(each.value, "signature_algorithm", "RSA_SHA256")
  digest_algorithm         = lookup(each.value, "digest_algorithm", "SHA256")
  honor_force_authn        = lookup(each.value, "honor_force_authn", true)
  authn_context_class_ref  = lookup(each.value, "authn_context_class_ref", "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport")
  sp_issuer                = lookup(each.value, "sp_issuer", null)
  acs_endpoints            = lookup(each.value, "acs_endpoints", null)
  attribute_statements     = lookup(each.value, "attribute_statements", null)
  hide_web                 = lookup(each.value, "hide_web", false)
  hide_ios                 = lookup(each.value, "hide_ios", false)
  user_name_template       = lookup(each.value, "user_name_template", null)
  user_name_template_type  = lookup(each.value, "user_name_template_type", "BUILT_IN")
  accessibility_self_service = lookup(each.value, "accessibility_self_service", false)
  auto_submit_toolbar      = lookup(each.value, "auto_submit_toolbar", false)
  authentication_policy = lookup(each.value, "authentication_policy_id", null)
  inline_hook_id = lookup(each.value, "inline_hook_id", null)
}

resource "okta_app_group_assignments" "this" {
  for_each = { for a in var.apps : a.label => a if lookup(a, "group_ids", null) != null }
  app_id = okta_app_saml.this[each.key].id
  dynamic "group" {
    for_each = each.value.group_ids
    content {
      id       = group.value
      priority = group.key + 1
    }
  }
}
