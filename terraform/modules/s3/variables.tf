variable "environment" {
  description = "dev environment"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN - KMS key for encryption"
  type        = string
}