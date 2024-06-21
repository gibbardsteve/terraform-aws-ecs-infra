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

variable "lb_delete_protection" {
  description = "Enable deletion protection for the load balancer"
  type        = bool
  default     = false
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

variable "default_response_allowed_ips" {
  description = "Default response allowed IPs"
  type        = list(string)
  default     = ["127.0.0.1/32"]
}

variable "alb_response_allowed_ips" {
  description = "ALB response allowed IPs"
  type        = list(string)
  default     = ["127.0.0.1/32"]
}

variable "github_audit_allowed_ips" {
  description = "Github Audit allowed IPs"
  type        = list(string)
  default     = ["127.0.0.1/32"]
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "project_tag" {
  description = "Project"
  type        = string
  default     = "SDP"
}

variable "team_owner_tag" {
  description = "Team Owner"
  type        = string
  default     = "Knowledge Exchange Hub"
}

variable "business_owner_tag" {
  description = "Business Owner"
  type        = string
  default     = "DST"
}


locals {
  url = "${var.domain}.${var.domain_extension}"
}