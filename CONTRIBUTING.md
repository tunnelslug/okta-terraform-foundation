# Contributing to okta-terraform-foundation

Thanks for improving this template. Keep it **reusable, secure, and multi-team friendly**.

## Ground rules

1. **No secrets** — never commit `*.tfvars`, `backend.hcl`, PEMs, webhook URLs, or real org IDs.
2. **No Okta API tokens** — OIDC API Services (`client_id` + `private_key`) only. See `docs/AUTH.md`.
3. **Modules stay pure** — no backends or company-specific values under `modules/`.
4. **Stacks own state** — env-specific wiring lives under `live/<env>/<stack>/`.
5. **Docs travel with code** — behavior changes should update `docs/` when relevant.

## Local checks before a PR

```bash
make fmt
make validate
make lint
make check-no-api-token
```

## PR checklist

- [ ] `terraform fmt -recursive` clean
- [ ] `make check-no-api-token` passes
- [ ] New modules include `variables.tf` / `outputs.tf` and a short purpose comment
- [ ] Examples still use placeholders only
- [ ] CODEOWNERS paths updated if you add a new stack

## Adding a module

1. Create `modules/<name>/` with `main.tf`, `variables.tf`, `outputs.tf`.
2. Wire it from the appropriate `live/dev/<stack>/` as an example.
3. Document ownership in `docs/OWNERSHIP.md` if it is a new domain.

## Adding a stack

1. Mirror `live/dev/identity/` structure.
2. Give it its own backend key pattern: `okta/<env>/<stack>/terraform.tfstate`.
3. Update CODEOWNERS, OWNERSHIP.md, and HOW_IT_WORKS.md.

## CI

- **GitHub Actions** (`.github/workflows/`) — fmt, validate, tflint, api-token guard, path-filtered plan.
- **AWS CodePipeline** (`ci/aws/`) — optional plan → Slack → approve → apply.

Plan/apply against real Okta orgs should only run with OIDC credentials from a secret store, never from the repo.
