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
- Adds EBS volume for instance in private subnet and EFS for Autoscaling group in public subnets. 
- Defines IAM roles and policies to securely grant EC2 instances access to AWS services like CloudWatch and S3.
- Added CloudWatch Dashboards showing CPU Utilization for ASG and private instance.
- Enabled SSM access to all instances by using session manager.

## Why I made it

I'm transitioning into a DevOps role, and this project helped me gain practical experience in deploying real AWS components using Terraform. It allowed me to get comfortable with modularization, resource dependencies, and managing environments declaratively.


## How to run

Make sure AWS CLI is configured and Terraform is installed, then:

1. terraform init
2. terraform plan
3. terraform apply


## Next steps

This project is not finished — I plan to keep expanding it by adding more AWS services.

Most recently, I added CloudWatch Dashboards and attached the necessary SSM policies to the EC2 IAM roles. My goal was to install the CloudWatch Agent via SSM RunCommand to push memory metrics to CloudWatch and test the dashboard functionality.

While Session Manager works, the RunCommand feature fails with “Access Denied”, even though the agent is running and the instance is managed. I suspect the issue might be related to IAM permissions, but I can't fully verify this as I’m currently using a restricted AWS playground environment where user policy visibility is limited.

I’m actively troubleshooting the SSM issue, as resolving it would allow me to validate CloudWatch metric collection and the dashboard setup.


