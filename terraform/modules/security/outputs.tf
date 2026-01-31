output "web_sg_id" {
  value = aws_security_group.web_sg.id
}

output "kms_key_arn" {
  description = "ARN - KMS key for encryption"
  value       = aws_kms_key.gcc_main_key.arn
}