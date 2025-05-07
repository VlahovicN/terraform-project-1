########  PROVIDER  ##########

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.96.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}


########### EC2-ACCESS-KEY #############

module "access_key" {
  source = "./modules/access_key"
}


######### AUTOSCALING and Instances ############

module "ASG_and_instances" {
  source = "./modules/ASG_and_instances"
  priv_subnet_id = module.vpc.priv_subnet_id
  public_subnet_ids = [
    module.vpc.public_subnet_1_id,
    module.vpc.public_subnet_2_id
  ]
  autoscaling_sg_id = module.security_groups.autoscaling_sg_id
  priv_subnet_sg = module.security_groups.priv_subnet_sg_id
  key_name = module.access_key.key_name
  target_group = module.Load_Balancers.target_group
  efs_sg = module.security_groups.efs_sg
  ec2_instance_profile_name = aws_iam_instance_profile.ec2_instance_profile.name
  public_subnet_1_id = module.vpc.public_subnet_1_id
  public_subnet_2_id = module.vpc.public_subnet_2_id
  region = "us-east-1"
}


#########  S3 BUCKETS  ##########

module "s3_buckets" {
  source = "./modules/s3bucket"
}


###########  VPC  ############

module "vpc" {
  source = "./modules/vpc"
}

########### LOAD BALANCERS ################

module "Load_Balancers" {
  source = "./modules/elb"
  vpc_id = module.vpc.vpc_id
  subnets = [
    module.vpc.public_subnet_1_id,
    module.vpc.public_subnet_2_id
  ]
  alb_sg_id = module.security_groups.alb_sg_id
}

############ SECURITY GROUPS ###############

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
}


######### RDS ###########

module "rds" {
  source = "./modules/rds"
  rds_sg = module.security_groups.rds_sg
  db_name = var.db_name
  username = var.username
  password = var.password
  db_subnets = [
   module.vpc.priv_subnet_id,
   module.vpc.priv_subnet_2_id
   ]
}


################ SNS #################

module "sns" {
  source = "./modules/sns"
}


############# CloudWatch ################

module "CloudWatch" {
  source = "./modules/cloudwatch"
  private_instance_id = module.ASG_and_instances.private_instance_id
  autoscaling_group = module.ASG_and_instances.autoscaling_group
  asg_action = module.ASG_and_instances.asg_action
  sns_action = module.sns.sns_topic_arn
}



################### IAM ########################

data "aws_iam_policy_document" "s3_access_and_cloudwatch_logs_policy" {
  statement {
    sid = "1"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [module.s3_buckets.bucket_arn_with_wildcard]
  }
    statement {
      sid = "2"
    actions = [ "s3:ListBucket" ]
     resources = [module.s3_buckets.bucket_arn]
    }

    statement {
      sid = "3"
      actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
      ]
      resources = ["arn:aws:logs:*:*:*"]
    }
}





resource "aws_iam_policy" "my_custom_policy" {
  name = "my_custom_policy"
  policy = data.aws_iam_policy_document.s3_access_and_cloudwatch_logs_policy.json
}




resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access_policy_attachment_to_ec2" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.my_custom_policy.arn
}


resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}

