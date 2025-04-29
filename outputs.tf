output "public_ip_public_subnet_instance" {
  value = aws_instance.new_instance.public_ip
}

output "public_subnett_instance_id" {
 value = aws_instance.new_instance.id
}

output "private_subnet_instance_id" {
  value = aws_instance.private_instance.id
}

output "private_ip_private_subnet_instance" {
  value = aws_instance.private_instance.private_ip
}