# Terraform AWS ECS Infrastructure

This Terraform assumes that the AWS account has been bootstrapped with a hosted zone domain in route 53.
It also assumes the terraform state is bootstrapped to be stored in S3 with a DynamoDB lock file to prevent conflicts.
You can bootstrap the terraform state using the repository [terraform-bootstrap](https://github.com/gibbardsteve/terraform-bootstrap)

The terraform then builds the necessary infrastructure components that can be used to make a Fargate service accessible via an application load balancer (ALB) using https.

To test that the ALB can be accessed via a series of restrictions the following sub-domains will return a response:

- alb-response._domain_name_
  - This will return a fixed HTML response from the ALB with status of 200 when access is allowed. Access is restricted based on the IP addresses specified in **alb_response_allowed_ips** variable.
  - When the source ip address is not in the variable then 403 Forbidden is displayed.

- default-response._domain_name_
  - This will return a fixed text response from the ALB with status of 404 when access is allowed. Access is restricted based on the IP addresses specified in **alb_response_allowed_ips** variable.
  - When the source ip address is not in the variable then 403 Forbidden is displayed.

- all-response._domain_name_ - This will return a fixed HTML response with status of 200.

The basic resources created by this infrastructure as code are:

- DNS Alias Records
- SSL Certificate
- VPC with Public and Private Subnets
- WAF (Web Application Firewall)
  - By default this is configured to block all traffic, you **must update with your allowed ip list** to receive a response from the ALB
  - If you are adding a service that needs to be allow listed by IP address then before provisioning your service you need to add:
    - An ipset with list of ips that are allowed
    - An appropriate rule in the ip_allow_rule_group
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

#### To allow ip addresses to _myservice_._domain_

Add an ipset and appropriate rule in this terraform matching the _myservice_ subdomain.  The rest of your service configuration can be provisioned in separate Terraform

#### Access to all-response._domain_

By default any IP address can navigate to all-response._domain_ and get a response from the ALB.

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

## Deploy the Terraform

The infrastructure is split into environments based on the following files:

- env/<dev|prod>/backend-<dev|prod>.tfbackend

  This file contains the terraform backend configuration for dev or prod environments.  This file is referenced when terraform init is applied.

- env/<dev|prod>/<dev|prod>.tfvars

  This is a local file contains the variable values used when running the terraform.  E.g this file would define the domain for the AWS account you are using, the account credentials and any ips that you want adding to WAF to whitelist.  The file is not stored in git.

To run the deploy:

- Initialise the backend using the appropriate environment config file

```bash
  cd terraform

  terraform init -backend-config=env/dev/backend-dev.tfbackend -reconfigure
```

- Refresh the local terraform state, pointing to the appropriate environment variable file:

```bash
  terraform refresh -var-file=env/dev/dev.tfvars 
```

- Apply the terraform, pointing to the appropriate environment variable file:

```bash
  terraform apply -var-file=env/dev/dev.tfvars
```

## Destroy the Terraform

To destroy the infrastructure resources any associated service resources must be deployed first.  Once this is done then the infrastructure can be destroyed using the following:

- Initialise the backend using the appropriate environment config file

```bash
  cd terraform

  terraform init -backend-config=env/dev/backend-dev.tfbackend -reconfigure
```

- Refresh the local terraform state, pointing to the appropriate environment variable file:

```bash
  terraform refresh -var-file=env/dev/dev.tfvars 
```

- Verify that the current plan (it should report no changes), pointing to the appropriate environment variable file:

```bash
  cd terraform

  terraform plan -var-file=env/dev/dev.tfvars
```

- Destroy the current resources, pointing to the appropriate environment variable file:

```bash
  cd terraform

  terraform destroy -var-file=env/dev/dev.tfvars
```
