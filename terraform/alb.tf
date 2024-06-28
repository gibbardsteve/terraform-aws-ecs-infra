#tfsec:ignore:aws-elb-alb-not-public
resource "aws_lb" "service_lb" {
  name               = "${var.domain}-service-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_rules_load_balancer.id]
  subnets            = module.vpc.public_subnets

  drop_invalid_header_fields = true
  enable_deletion_protection = var.lb_delete_protection

}

# Redirect HTTP to HTTPS
resource "aws_alb_listener" "app_http" {
  load_balancer_arn = aws_lb.service_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      status_code = "HTTP_301"
      protocol    = "HTTPS"
    }
  }

}

resource "aws_lb_listener" "app_https" {
  load_balancer_arn = aws_lb.service_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "ALB Default Response"
      status_code  = "404"
    }
  }

  # Can only use a validated certificate 
  depends_on = [aws_acm_certificate_validation.cert]
}

resource "aws_lb_listener_rule" "test_response" {
  listener_arn = aws_lb_listener.app_https.arn
  priority     = 1

  condition {
    host_header {
      values = ["alb-response.${local.url}"]
    }
  }

  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/html"
      message_body = "<html><body><h1>ALB Response</h1><p>This is a test response</p></body></html>"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "all_ip_response" {
  listener_arn = aws_lb_listener.app_https.arn
  priority     = 2

  condition {
    host_header {
      values = ["all-response.${local.url}"]
    }
  }

  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/html"
      message_body = "<html><body><h1>Response Available from Any IP</h1><p>This is a test response</p></body></html>"
      status_code  = "200"
    }
  }
}