# Backend will be overwritten by env specific backend using the command
# terraform init -backend-config="path/to/backend-<env>.tf"

terraform {
  backend "s3" {
    # backend config is selected by running terraform init -backend-config="path/to/backend-<env>.tfbackend"  }
  }
}

resource "aws_ecs_cluster" "service_cluster" {
  name = "service-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "service_providers" {
  cluster_name = aws_ecs_cluster.service_cluster.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]


}
