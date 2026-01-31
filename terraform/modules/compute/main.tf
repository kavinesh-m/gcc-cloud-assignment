data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_iam_role" "web_role" {
  name = "${var.environment}-web-server-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_instance_profile" "web_profile" {
  name = "${var.environment}-web-server-profile"
  role = aws_iam_role.web_role.name
}

resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  associate_public_ip_address = true

  user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install -y httpd
                sudo systemctl start httpd
                sudo systemctl enable httpd

                TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
                INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)

                echo "<h1>GCC Assignment: Web Tier Test</h1><p>Instance ID: $INSTANCE_ID</p>" > /var/www/html/index.html
              EOF

  tags = {
    Name        = "${var.environment}-web-server"
    Environment = var.environment
    Compliance  = "Public-Demo-Only"
  }
}

resource "aws_iam_role_policy" "web_s3_kms_policy" {
  name = "${var.environment}-web-s3-kms-policy"
  role = aws_iam_role.web_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:ListBucket"
        ]
        # Use the variable here!
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ]
        Resource = [var.kms_key_arn]
      }
    ]
  })
}