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




### VPC and Networking
- 1 VPC
- 2 public subnets (used for Application Load Balancer and Auto Scaling Group)
- 2 private subnets (used for EC2 instance and RDS)
- 1 Internet Gateway for public subnets
- 1 NAT Gateway for private subnets
- Route tables for both public and private traffic

### Security Groups
- Security group for Application Load Balancer (allows HTTP on port 80 from anywhere)
- Security Group for ASG-EC2 Instances (Allows HTTP from ALB SG, SSH access from anywhere because of testing, and ICMP from priv subnets SG)
- Security Group for EC2 instance in private subnet (allows SSH and ICMP from public subnet SG)
- Security group for RDS (allows inbound MySQL port 3306 only from ASG EC2 security group)
- Security group for EFS (allows NFS port 2049 only from ASG EC2 security group)
- All Security Groups (except RDS SG) have all outbound traffic enabled. 

### Compute
Auto Scaling Group (ASG) that launches EC2 instances in public subnets:
- Launch template with user data script to:
  - Install NGINX and NFS
  - Mount NFS file system

EC2 instance in private subnet with userdata script which mount EBS volume
 

### Load Balancer
- Application Load Balancer in public subnets
- Listener on port 80 that forwards traffic to target group (ASG EC2 instances)

### Storage
- EBS volume attached and mounted to private EC2 instance
- EFS file system mounted on ASG EC2 instances
- S3 bucket for storing static web content (HTML)

### Database
- RDS MySQL database deployed in private subnet
- Access allowed only from EC2 (private subnet) security group

### Monitoring
- CloudWatch Alarm for EC2 CPU utilization (both ASG and private EC2 instance)
- SNS Topic to send email notifications on alarm trigger

### IAM
- IAM Role for EC2 with access to:
  - CloudWatch
  - S3
  - EFS
  - SSM




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


