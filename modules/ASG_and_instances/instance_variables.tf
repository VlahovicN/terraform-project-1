variable "ami" {
  default = "ami-053b0d53c279acc90"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "priv_subnet_id" {}

variable "public_subnet_ids" {
  type = list(string)
}


variable "key_name" {}


variable "autoscaling_sg_id" {}

variable "priv_subnet_sg" {}

variable "target_group" {
  type = list(string)
}

variable "public_subnet_1_id" {}
variable "public_subnet_2_id" {}


variable "efs_sg" {}

variable "region" {}

variable "ec2_instance_profile_name" {}