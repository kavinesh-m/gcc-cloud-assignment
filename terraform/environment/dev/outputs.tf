output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "Public subnet IP list"
  value       = module.vpc.public_subnets
}

output "web_security_group_id" {
  description = "Security Group ID"
  value       = module.security.web_sg_id
}

output "web_server_public_ip" {
  description = "Web server public IP"
  value       = module.compute.instance_public_ip
}