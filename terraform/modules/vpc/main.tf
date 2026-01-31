module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.3"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true 
  
  enable_dns_hostnames = true
  enable_dns_support   = true

  # GCC Compliance: Enable Flow Logs
  enable_flow_log                  = false
  create_flow_log_cloudwatch_iam_role = false
  create_flow_log_cloudwatch_log_group = false

  tags = {
    Environment = "dev"
    Project     = "GCCAssignment"
  }
}

resource "aws_cloudwatch_log_group" "flow_log" {
  name              = "/aws/vpc-flow-logs/${var.environment}"
  retention_in_days = 30
  kms_key_id        = var.kms_key_arn 
}

resource "aws_flow_log" "main" {
  iam_role_arn    = aws_iam_role.vpc_flow_log_role.arn 
  log_destination = aws_cloudwatch_log_group.flow_log.arn
  traffic_type    = "ALL"
  vpc_id = module.vpc.vpc_id
}

resource "aws_iam_role" "vpc_flow_log_role" {
  name = "${var.environment}-vpc-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "vpc_flow_log_policy" {
  name = "${var.environment}-vpc-flow-log-policy"
  role = aws_iam_role.vpc_flow_log_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogGroups", "logs:DescribeLogStreams"]
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}