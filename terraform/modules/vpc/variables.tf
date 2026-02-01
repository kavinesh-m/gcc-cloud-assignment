variable "vpc_name" { type = string }
variable "vpc_cidr" { type = string }
variable "azs" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "public_subnets" { type = list(string) }
variable "kms_key_arn" {
  description = "ARN - KMS key for log encryption"
  type        = string
}
variable "environment" {
  type        = string
  default     = "dev"
}