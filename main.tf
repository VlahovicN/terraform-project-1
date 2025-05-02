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


########### EC@-ACCESS-KEY #############

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
}


#########  S# BUCKETS  ##########

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