variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "environment" {
  description = "dev environment"
  type        = string
  default     = "dev"
}