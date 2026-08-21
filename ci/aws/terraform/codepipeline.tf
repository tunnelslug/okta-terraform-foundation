resource "aws_sns_topic" "pipeline_approvals" {
  name = "${var.project_name}-pipeline-approvals"
  tags = var.tags
}

resource "aws_codepipeline" "okta" {
  name     = "${var.project_name}-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = local.artifacts_bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = "${var.github_owner}/${var.github_repo}"
        BranchName       = var.github_branch
        DetectChanges    = "true"
      }
    }
  }

  stage {
    name = "Plan"

    action {
      name             = "TerraformPlan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["plan_output"]

      configuration = {
        ProjectName = aws_codebuild_project.plan.name
      }
    }
  }

  dynamic "stage" {
    for_each = var.enable_apply_stage ? [1] : []
    content {
      name = "Approve"

      action {
        name     = "ManualApproval"
        category = "Approval"
        owner    = "AWS"
        provider = "Manual"
        version  = "1"

        configuration = {
          NotificationArn = aws_sns_topic.pipeline_approvals.arn
          CustomData      = "Review Slack plan notification, then approve to apply changed Okta stacks."
        }
      }
    }
  }

  dynamic "stage" {
    for_each = var.enable_apply_stage ? [1] : []
    content {
      name = "Apply"

      action {
        name            = "TerraformApply"
        category        = "Build"
        owner           = "AWS"
        provider        = "CodeBuild"
        version         = "1"
        input_artifacts = ["source_output"]

        configuration = {
          ProjectName = aws_codebuild_project.apply.name
        }
      }
    }
  }

  tags = var.tags
}
