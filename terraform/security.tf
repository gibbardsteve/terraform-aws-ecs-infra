# Security groups to allow and deny traffic
resource "aws_security_group" "allow_rules_load_balancer" {
  name        = "allow-rules-lb"
  description = "Allow inbound https traffic on port 443 and redirect http traffic from port 80"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description = "Redirect HTTP to HTTPS"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow inbound traffic on port 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a web application firewall
# Define IP sets
resource "aws_wafv2_ip_set" "allowed_ips_alb_response_subdomain" {
  name        = "allowed-ips-alb-response-subdomain"
  description = "Allowed IPs for the alb-response subdomain"
  scope       = "REGIONAL"

  # Add the IP addresses that are allowed to access the alb-response subdomain
  # loopback is allowed in this example - Must UPDATE with your allowed IP lists
  ip_address_version = "IPV4"
  addresses          = ["127.0.0.1/32"]

}

resource "aws_wafv2_ip_set" "allowed_ips_default_response_subdomain" {
  name        = "allowed-ips-default-response-subdomain"
  description = "Allowed IPs for the default-response subdomain"
  scope       = "REGIONAL"

  ip_address_version = "IPV4"

  # Add the IP addresses that are allowed to access the default-response subdomain
  # loopback is allowed in this example - Must UPDATE with your allowed IP lists
  addresses = ["127.0.0.1/32"
  ]

}

resource "aws_wafv2_rule_group" "ip_allow_rule_group" {
  capacity = 20
  name     = "ip-allow-rule-group"
  scope    = "REGIONAL"

  rule {
    name     = "alb-response-rule"
    priority = 1

    action {
      allow {}
    }

    statement {
      and_statement {
        statement {
          ip_set_reference_statement {
            arn = aws_wafv2_ip_set.allowed_ips_alb_response_subdomain.arn
          }
        }

        statement {
          byte_match_statement {
            search_string = "default-response.${local.url}"
            field_to_match {
              single_header {
                name = "host"
              }
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
            positional_constraint = "EXACTLY"
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "alb-response-metric"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "default-response-rule"
    priority = 2

    action {
      allow {}
    }

    statement {
      and_statement {
        statement {
          ip_set_reference_statement {
            arn = aws_wafv2_ip_set.allowed_ips_default_response_subdomain.arn
          }
        }

        statement {
          byte_match_statement {
            search_string = "default-response.${local.url}"
            field_to_match {
              single_header {
                name = "host"
              }
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
            positional_constraint = "EXACTLY"
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "default-response-metric"
      sampled_requests_enabled   = false
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "ips-allowed-metric"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl" "web_firewall" {
  name  = "waf-allowed-ips"
  scope = "REGIONAL"

  default_action {
    block {}
  }

  rule {
    name     = "allow-rule-1"
    priority = 1

    override_action {
      none {}
    }

    statement {
      rule_group_reference_statement {
        arn = aws_wafv2_rule_group.ip_allow_rule_group.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "friendly-rule-metric-name"
      sampled_requests_enabled   = false
    }
  }

  tags = {
    Tag1 = "Value1"
    Tag2 = "Value2"
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "friendly-metric-name"
    sampled_requests_enabled   = false
  }
}

# Associate WAF rules with ALB
resource "aws_wafv2_web_acl_association" "alb_association" {
  resource_arn = aws_lb.service_lb.arn
  web_acl_arn  = aws_wafv2_web_acl.web_firewall.arn
}