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

# SG - Service specific - move to service module
# consider restricting traffic here
# resource "aws_security_group" "allow_rules_service" {
#   name        = "allow-rule-service"
#   description = "Allow inbound traffic on port ${var.container_port} from ${var.from_port} on the service"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     from_port   = var.from_port
#     to_port     = var.container_port
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# To restrict to VPN and ONS onsite
# cidr_blocks = ["194.34.204.36/32",
#                "194.34.204.37/32",
#                "194.34.206.36/32",
#                "194.34.206.37/32",
#                "155.190.13.19/32",
#                "155.190.35.77/32",
#                "155.190.60.38/32"]
