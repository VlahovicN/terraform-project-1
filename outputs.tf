output "private_subnet_instance_id" {
  value = module.ASG_and_instances.private_subnet_instance_id
}

output "private_ip_private_subnet_instance" {
  value = module.ASG_and_instances.private_ip_private_subnet_instance
}


output "alb_dns_name" {
  value = module.Load_Balancers.terraform-alb_dns_name
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_instance_profile.name
}

output "ec2_instance_profile_name2" {
  value = aws_iam_instance_profile.ec2_instance_profile2.name
}