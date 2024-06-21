output "ecs_cluster_id" {
  value = aws_ecs_cluster.service_cluster.id
}

output "ecs_cluster_arn" {
  value = aws_ecs_cluster.service_cluster.arn
}

output "ecs_cluster_capacity_providers_id" {
  value = aws_ecs_cluster_capacity_providers.service_providers.id
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "main_vpc_id" {
  value = data.aws_vpc.main.id
}

output "service_lb_dns_name" {
  value = aws_lb.service_lb.dns_name
}

output "service_lb_zone_id" {
  value = aws_lb.service_lb.zone_id
}

output "application_lb_arn" {
  value = aws_lb.service_lb.arn
}

output "application_lb_https_listener_arn" {
  value = aws_lb_listener.app_https.arn
}

output "web_firewall_arn" {
  value = aws_wafv2_web_acl.web_firewall.arn
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "alb_response_url" {
  value = "alb-response.${local.url}"
}

output "default_response_url" {
  value = "default-response.${local.url}"
}

output "all_response_url" {
  value = "all-response.${local.url}"
}