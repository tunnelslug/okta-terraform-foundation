# Ownership & Split-State Model

This template is designed so **multiple teams can safely co-own one Okta org** without stepping on each other.

## Ownership domains (stacks)

| Stack | Owns | Typical team |
|-------|------|--------------|
| **identity** | Groups, group rules, authenticators, network zones | Identity / IAM platform |
| **apps** | OAuth/OIDC apps, SAML apps, app group assignments | App / product IAM |
| **policies** | Global session, app sign-on, MFA, password policies | Security / IAM |
| **authz** | Custom authorization servers, scopes, claims, trusted origins | API / platform security |
| **governance** | Governance labels, custom admin roles, resource sets, event hooks | Governance / GRC |

## How stacks talk to each other

Downstream stacks read upstream outputs via `terraform_remote_state` (read-only).

## Recommended apply order

```
1. identity
2. policies
3. apps
4. authz
5. governance (independent; can run anytime)
```

## Backend isolation

Each `live/<env>/<stack>/` directory has its **own** backend key:

```
s3://bucket/okta/dev/identity/terraform.tfstate
s3://bucket/okta/dev/apps/terraform.tfstate
```
