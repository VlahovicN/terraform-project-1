output "private_subnet_instance_id" {
  value = aws_instance.private_instance.id
}

output "private_ip_private_subnet_instance" {
  value = aws_instance.private_instance.private_ip
}

output "autoscaling_group" {
  value = aws_autoscaling_group.autoscale.name
}

output "asg_action" {
  value = aws_autoscaling_policy.CPU_Policy.arn
}

output "private_instance_id" {
  value = aws_instance.private_instance.id
}

output "efs_id" {
  value = aws_efs_file_system.my_efs.id
}