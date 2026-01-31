resource "aws_security_group" "alb_sg" {
  name        = "${var.environment}-alb-sg"
  vpc_id      = var.vpc_id
  description = "Security group for ALB"

  # Allow HTTP (Port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS (Port 443)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "main" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids 

  enable_deletion_protection = false 
}

resource "aws_lb_target_group" "app" {
  name        = "${var.environment}-app-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" 

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# HTTP to HTTPS Redirect
resource "aws_lb_listener_rule" "redirect_http_to_https" {
  listener_arn = aws_lb_listener.http.arn 
  priority     = 1

  action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

# Generate Private Key
resource "tls_private_key" "tlsprivatekey1" {
  algorithm = "RSA"
}

# Create Self-Signed Cert
resource "tls_self_signed_cert" "tlsselfsignedcert1" {
  private_key_pem = tls_private_key.tlsprivatekey1.private_key_pem

  subject {
    common_name  = "gcc-assignment.local"
    organization = "GCC Assignment"
  }

  validity_period_hours = 8760 

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

# Import Cert to AWS ACM
resource "aws_acm_certificate" "cert" {
  private_key      = tls_private_key.tlsprivatekey1.private_key_pem
  certificate_body = tls_self_signed_cert.tlsselfsignedcert1.cert_pem
}

# Create the HTTPS Listener (Port 443)
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06" 
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}