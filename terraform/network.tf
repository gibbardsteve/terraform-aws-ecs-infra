module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.1"

  name            = var.domain
  cidr            = var.cidr
  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  create_egress_only_igw = false
  create_igw             = true

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  default_security_group_name = "${var.domain}-vpc-default-sg"

  default_security_group_ingress = []
  default_security_group_egress  = []

  manage_default_security_group = true
  default_security_group_tags = {
    Name                 = "${var.domain}-vpc-default-sg"
    DefaultSecurityGroup = "true"
  }

  manage_default_route_table = true
  default_route_table_tags = {
    Name              = "${var.domain}-vpc-default-rt"
    DefaultRouteTable = "true"
  }

  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

}