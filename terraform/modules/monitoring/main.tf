# Metric Filter to count REJECTED traffic in VPC
resource "aws_cloudwatch_log_metric_filter" "vpc_reject_filter" {
  name           = "VPC-Unauthorized-Access-Attempts"
  pattern        = "[version, account_id, interface_id, srcaddr, dstaddr, srcport, dstport, protocol, packets, bytes, start, end, action=\"REJECT\", log_status]"
  log_group_name = var.flow_log_group_name

  metric_transformation {
    name      = "VPCRejectCount"
    namespace = "GCC/Compliance"
    value     = "1"
  }
}

# Alarm 
resource "aws_cloudwatch_metric_alarm" "unauthorized_access_alarm" {
  alarm_name          = "${var.environment}-unauthorized-access-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "VPCRejectCount"
  namespace           = "GCC/Compliance"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10" 
  alarm_description   = "This alarm monitors for unauthorized access attempts in the VPC."
  actions_enabled     = true
}