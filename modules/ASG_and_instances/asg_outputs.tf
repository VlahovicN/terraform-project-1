output "private_subnet_instance_id" {
  value = aws_instance.private_instance.id
}

output "private_ip_private_subnet_instance" {
  value = aws_instance.private_instance.private_ip
}