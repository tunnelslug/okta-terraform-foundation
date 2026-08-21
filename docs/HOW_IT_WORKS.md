# How okta-terraform-foundation works

Modular multi-stack Okta Terraform foundation:

- **Modules** under `modules/` (pure, no state)
- **Stacks** under `live/<env>/<stack>/` (ownership + state)
- **OIDC-only** auth (no API tokens)
- **Split state** (S3 or GCS per stack)
- **Import path** for existing orgs (`docs/IMPORT.md`)

## Stacks

| Stack | Owns |
|-------|------|
| identity | Groups, group rules, authenticators, network |
| apps | OAuth/SAML apps + assignments |
| policies | Session, app sign-on, MFA, password |
| authz | Auth servers, scopes, claims, trusted origins |
| governance | Labels, admin roles, event hooks |

Apply order: identity → policies → apps → authz (governance independent).

See also: OWNERSHIP, AUTH, IMPORT, ADOPTING, CI_GITHUB, CI_AWS, APP_TRACKING.
