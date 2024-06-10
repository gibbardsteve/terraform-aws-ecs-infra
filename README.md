# Terraform

This terraform assumes that the AWS account has been bootstrapped with a domain in route 53.
You can bootstrap a domain using the repository [terraform-bootstrap](https://github.com/gibbardsteve/terraform-bootstrap)

The terraform then builds the necessary infrastructure components that can be used to make a Fargate service accessible via an application load balancer (ALB) using https.

The basic resources created by this infrastructure as code are:

- DNS Alias Records
- SSL Certificate
- VPC with Public and Private Subnets
- WAF (Web Application Firewall)
  - By default this is configured to block all traffic, you **must update with your allowed ip list** to receive a response from the ALB
- ALB (Application Load Balancer)
  - Listener rules send success and error response for two specific subdomains (alb-response.example.com and default-response.example.com)
- NAT Gateway (Network Address Translation)
- Security Group


## Main Components

### Network

A new VPC is created with public and private subnets.

### Route 53

Used to define a DNS lookup for the domain name. An alias is created to pass all requests to the public facing application load balancer.

### Certificate Manager

Used to create an SSL certificate for the domain name (wildcard for subdomains). The terraform will validate the certificate using DNS and create a CNAME entry in Route 53.

### Security Groups

A security group is attached to the public facing application load balancer. This allows traffic on port 80 (http) and redirects to 443 (https).  Traffic received on 443 is defaulted to return a fixed response by the load balancer.

### Web Application Firewall Rules

WAF rules are defined that allow traffic from a defined set of IP addresses per subdomain.  This allows a list of addresses to be filtered before the ALB, meaning that traffic can be allowed or denied per subdomain before (optional) authentication processing occurs at the ALB.

#### To allow ip addresses to alb-response._domain_

Update the list in the ip_set allowed-ips-alb-response-subdomain.  
_Note: By default **all traffic will be blocked** as only loopback address is specified_

#### To allow ip addresses to default-response._domain_

Update the list in the ip_set allowed-ips-default-response-subdomain.  
_Note: By default **all traffic will be blocked** as only loopback address is specified_

### Application Load Balancer

The load balancer terminates public traffic.

The load balancer will redirect any http traffic to port 443 so that all traffic must be served over TLS (using https). There are listener rules to:

- send a fixed successful response back when alb-response._domain-name_ is navigated to.

- send a fixed 404 response back when default-response._domain-name_ is navigated to.

### Elastic Container Service

#### Cluster

A cluster that can dynamically allocate resources from FARGATE and FARGATE_SPOT.

**Note:** Dynamic allocation based on traffic increase/decrease is **TODO**.

This provides the basic infrastructure in AWS for the service to define it's own bespoke terraform to create a service, task-definition, target-group and any security-group rules or cognito requirements specific to that service. The service terraform would then apply the target-group to the load balancer created by this configuration to have traffic for warded to the service.
