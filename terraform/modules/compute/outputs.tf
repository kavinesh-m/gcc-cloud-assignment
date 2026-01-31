output "instance_public_ip" {
  description = "EC2 Public IP"
  value       = aws_instance.web_server.public_ip
}

output "instance_id" {
  description = "EC2 ID"
  value       = aws_instance.web_server.id
}