variable "environment" { type = string }
variable "kms_key_arn" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "security_group_ids" {type = list(string)}
variable "target_group_arn" {type = string}
variable "container_image" {type = string}