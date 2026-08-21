resource "aws_s3_bucket" "artifacts" {
  count  = var.create_artifacts_bucket ? 1 : 0
  bucket = var.artifacts_bucket_name != "" ? var.artifacts_bucket_name : "${var.project_name}-pipeline-artifacts-${data.aws_caller_identity.current.account_id}"

  tags = merge(var.tags, { Name = "${var.project_name}-artifacts" })
}

resource "aws_s3_bucket_versioning" "artifacts" {
  count  = var.create_artifacts_bucket ? 1 : 0
  bucket = aws_s3_bucket.artifacts[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  count  = var.create_artifacts_bucket ? 1 : 0
  bucket = aws_s3_bucket.artifacts[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  count  = var.create_artifacts_bucket ? 1 : 0
  bucket = aws_s3_bucket.artifacts[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_caller_identity" "current" {}

locals {
  artifacts_bucket = var.create_artifacts_bucket ? aws_s3_bucket.artifacts[0].bucket : var.artifacts_bucket_name
}
