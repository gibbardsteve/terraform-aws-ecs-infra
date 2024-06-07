terraform {
  backend "s3" {
    bucket         = "sdp-dev-tf-state"
    key            = "sdp-dev-ecs-infra/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-state-lock"
  }
}

resource "aws_ecs_cluster" "service_cluster" {
  name = "service-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "service_providers" {
  cluster_name = aws_ecs_cluster.service_cluster.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]


}
