variable "instance_type" {
  default = "t3.micro"
}

variable "subnet_id" {
  description = "subnet"
}

variable "security_group_ids" {
  type = list(string)
}

variable "environment" {
  type = string
}

variable "kms_key_arn" {
  type = string
}

variable "s3_bucket_arn" {
  description = "ARN - S3 bucket for logs"
  type        = string
}