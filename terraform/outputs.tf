output "ecs_cluster_id" {
  value = aws_ecs_cluster.service_cluster.id
}

output "ecs_cluster_arn" {
  value = aws_ecs_cluster.service_cluster.arn
}

output "ecs_cluster_capacity_providers_id" {
  value = aws_ecs_cluster_capacity_providers.service_providers.id
}

# SG - This is service specific. MUST BE MOVED TO THE SERVICE MODULE
# output "ecs_task_definition_arn" {
#   value = aws_ecs_task_definition.ecs_service_definition.arn
# }

# output "ecs_task_definition_revision" {
#   value = aws_ecs_task_definition.ecs_service_definition.revision
# }

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "main_vpc_id" {
  value = data.aws_vpc.main.id
}

# SG - This is service specific. MUST BE MOVED TO THE SERVICE MODULE
# output "security_group_id" {
#   value = aws_security_group.allow_rules_service.id
# }

# output "public_ip" {
#   value = data.aws_network_interface.interface_tags.association[0].public_ip
# }

output "service_domain" {
  value = "${var.service_subdomain}.${local.url}"
}

output "service_lb_dns_name" {
  value = aws_lb.service_lb.dns_name
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