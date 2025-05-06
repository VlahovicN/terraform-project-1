# Terraform AWS Infrastructure – Practice Project

This is a practice project I built while learning Terraform. The goal was to get hands-on with AWS and understand how to define infrastructure as code using Terraform.

## What it does

- Creates a VPC with public and private subnets  
- Sets up an Internet Gateway and route table  
- Launches EC2 instances via Auto Scaling and Launch Template  
- Adds an Application Load Balancer  
- Creates an S3 bucket with a basic HTML file  
- Configures Security Groups for SSH and HTTP access
- Deploys an RDS MySQL instance in private subnets with subnet group and SG isolation
- Adds CloudWatch Alarms with SNS notifications for CPU monitoring and auto-scaling triggers
- Added EBS volume for private instance and EFS for 

## Why I made it

I'm transitioning into a DevOps role, and this project helped me gain practical experience in deploying real AWS components using Terraform. It allowed me to get comfortable with modularization, resource dependencies, and managing environments declaratively.


## How to run

Make sure AWS CLI is configured and Terraform is installed, then:

1. terraform init
2. terraform plan
3. terraform apply


## Next steps

This project is not finished — I plan to keep expanding it by adding more AWS services.
