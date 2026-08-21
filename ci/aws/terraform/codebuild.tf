resource "aws_codebuild_project" "plan" {
  name          = "${var.project_name}-plan"
  description   = "Terraform plan for changed Okta stacks + Slack notification"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 60

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false

    environment_variable {
      name  = "TERRAFORM_VERSION"
      value = var.terraform_version
    }
    environment_variable {
      name  = "DEFAULT_BRANCH"
      value = var.github_branch
    }
    environment_variable {
      name  = "DEFAULT_ENV"
      value = var.default_env
    }
    environment_variable {
      name  = "FORCE_ALL_ON_MODULE_CHANGE"
      value = var.plan_on_module_change ? "true" : "false"
    }
    environment_variable {
      name  = "OKTA_SECRET_ARN"
      value = var.okta_credentials_secret_arn
    }
    environment_variable {
      name  = "CODEPIPELINE_NAME"
      value = "${var.project_name}-pipeline"
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
    environment_variable {
      name  = "SLACK_WEBHOOK_URL"
      value = var.slack_webhook_secret_arn
      type  = "SECRETS_MANAGER"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "ci/aws/codebuild/buildspec-plan.yml"
  }

  tags = merge(var.tags, { Stage = "plan" })
}

resource "aws_codebuild_project" "apply" {
  name          = "${var.project_name}-apply"
  description   = "Terraform apply for changed Okta stacks + Slack notification"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 60

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false

    environment_variable {
      name  = "TERRAFORM_VERSION"
      value = var.terraform_version
    }
    environment_variable {
      name  = "DEFAULT_BRANCH"
      value = var.github_branch
    }
    environment_variable {
      name  = "DEFAULT_ENV"
      value = var.default_env
    }
    environment_variable {
      name  = "OKTA_SECRET_ARN"
      value = var.okta_credentials_secret_arn
    }
    environment_variable {
      name  = "CODEPIPELINE_NAME"
      value = "${var.project_name}-pipeline"
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
    environment_variable {
      name  = "SLACK_WEBHOOK_URL"
      value = var.slack_webhook_secret_arn
      type  = "SECRETS_MANAGER"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "ci/aws/codebuild/buildspec-apply.yml"
  }

  tags = merge(var.tags, { Stage = "apply" })
}
