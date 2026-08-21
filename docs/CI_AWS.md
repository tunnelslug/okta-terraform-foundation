# AWS CodePipeline + Slack

Scaffold under `ci/aws/`:

1. Path-filtered plan on changed `live/<env>/<stack>`
2. Slack notification with CodeBuild/CodePipeline links
3. Manual approval
4. Apply + Slack result

Deploy pipeline: `cd ci/aws/terraform && terraform apply` (fill tfvars with CodeStar connection, secret ARNs, state bucket).

Still OIDC-only for Okta — credentials from Secrets Manager.
