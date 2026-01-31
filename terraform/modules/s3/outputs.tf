output "bucket_id" {
  value = aws_s3_bucket.gcc_logs.id
}

output "bucket_arn" {
  value = aws_s3_bucket.gcc_logs.arn
}