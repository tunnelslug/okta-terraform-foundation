# Contributing to okta-terraform-foundation

Thanks for improving this template. Keep it reusable, secure, and multi-team friendly.

## Ground rules

1. No secrets — never commit `*.tfvars`, `backend.hcl`, PEMs, webhook URLs, or real org IDs.
2. No Okta API tokens — OIDC API Services (`client_id` + `private_key`) only. See `docs/AUTH.md`.
3. Modules stay pure — no backends or company-specific values under `modules/`.
4. Stacks own state — env-specific wiring lives under `live/<env>/<stack>/`.
5. Docs travel with code — behavior changes should update `docs/` when relevant.

## Local checks before a PR

```bash
make fmt
make validate
make lint
make check-no-api-token
```

## CI

- GitHub Actions (`.github/workflows/`) — fmt, validate, tflint, api-token guard, path-filtered plan.
- AWS CodePipeline (`ci/aws/`) — optional plan → Slack → approve → apply.
