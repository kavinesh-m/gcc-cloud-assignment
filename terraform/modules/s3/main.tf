data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "gcc_logs" {
  bucket        = "gcc-logs-${var.environment}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true 

  tags = {
    Name        = "${var.environment}-gcc-logs"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "gcc_logs_access" {
  bucket = aws_s3_bucket.gcc_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "gcc_logs_encryption" {
  bucket = aws_s3_bucket.gcc_logs.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}