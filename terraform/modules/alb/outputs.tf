output "alb_dns_name" {
  description = "DNS for load balancer"
  value       = aws_lb.main.dns_name
}

output "alb_target_group_arn" {
  description = "ARN of the target group for ECS"
  value       = aws_lb_target_group.app.arn
}

output "alb_security_group_id" {
  description = "SG ID of the ALB for ECS ingress rules"
  value       = aws_security_group.alb_sg.id
}

output "alb_url" {
  value = "https://${aws_lb.main.dns_name}"
}