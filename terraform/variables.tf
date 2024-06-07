variable "app_name" {
  description = "Application name"
  type        = string
  default     = "sdp"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
}

variable "container_image" {
  description = "Container image"
  type        = string
  default     = "sdp-repo-archive"
}

variable "container_tag" {
  description = "Container tag"
  type        = string
  default     = "v0.0.1"

}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 5000
}

variable "from_port" {
  description = "From port"
  type        = number
  default     = 5000
}

variable "destroy_hosted_zone" {
  description = "Optionally destroy the Route53 hosted zone"
  type        = bool
  default     = false
}

variable "domain" {
  description = "Domain"
  type        = string
  default     = "sdp-sandbox"
}

variable "domain_extension" {
  description = "Domain extension"
  type        = string
  default     = "aws.onsdigital.uk"
}

variable "log_retention_days" {
  description = "Log retention days"
  type        = number
  default     = 90
}

variable "lb_delete_protection" {
  description = "Enable deletion protection for the load balancer"
  type        = bool
  default     = false
}

variable "service_subdomain" {
  description = "Service subdomain"
  type        = string
  default     = "github-audit"
}

variable "service_cpu" {
  description = "Service CPU"
  type        = string
  default     = "1024"
}

variable "service_memory" {
  description = "Service memory"
  type        = string
  default     = "3072"
}

variable "task_count" {
  description = "Number of instances of the service to run"
  type        = number
  default     = 1
}

variable "cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.30.172.0/22"
}

variable "public_subnets" {
  description = "Public subnets"
  type        = list(string)
  default     = ["10.30.175.0/26", "10.30.175.64/26", "10.30.175.128/26"]
}

variable "private_subnets" {
  description = "Private subnets"
  type        = list(string)
  default     = ["10.30.172.0/24", "10.30.173.0/24", "10.30.174.0/24"]

}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

locals {
  url = "${var.domain}.${var.domain_extension}"
}