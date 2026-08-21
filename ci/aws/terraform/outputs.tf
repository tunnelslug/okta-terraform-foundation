output "pipeline_name" {
  value = aws_codepipeline.okta.name
}

output "pipeline_arn" {
  value = aws_codepipeline.okta.arn
}

output "codebuild_plan_project" {
  value = aws_codebuild_project.plan.name
}

output "codebuild_apply_project" {
  value = aws_codebuild_project.apply.name
}

output "artifacts_bucket" {
  value = local.artifacts_bucket
}

output "approval_sns_topic_arn" {
  value = aws_sns_topic.pipeline_approvals.arn
}

output "console_pipeline_url" {
  value = "https://${var.aws_region}.console.aws.amazon.com/codesuite/codepipeline/pipelines/${aws_codepipeline.okta.name}/view?region=${var.aws_region}"
}
