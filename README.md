# Terraform AWS Infrastructure – Practice Project

This is a practice project I built while learning Terraform. The goal was to get hands-on with AWS and understand how to define infrastructure as code using Terraform.

## What it does

- Creates a VPC with public and private subnets  
- Sets up an Internet Gateway and route table  
- Launches EC2 instances via Auto Scaling and Launch Template  
- Adds an Application Load Balancer  
- Creates an S3 bucket with a basic HTML file  
- Configures Security Groups for SSH and HTTP access

## Why I made it

I'm transitioning into DevOps, and this project helped me understand how AWS resources connect and how to manage them using Terraform. Nothing fancy, just solid basics done right.

## How to run

Make sure AWS CLI is configured and Terraform is installed, then:

terraform init
terraform plan
terraform apply


## Next steps

This repo isn’t finished — I constantly improve the code and gradually add more AWS services as part of my learning process.  
The goal is to turn this into a more complete and modular infrastructure setup over time.
