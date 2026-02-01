variable "environment" {
  description = "dev environment"
  type        = string
  default     = "dev"
}

variable "vpc_name" {
  type    = string
  default = "gcc-vpc-dev"
}

variable "container_image_tag" {
  type        = string
  default     = "latest"
}

