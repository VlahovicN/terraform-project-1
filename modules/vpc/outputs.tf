output "vpc_id" {
  value = aws_vpc.new.id
}

output "priv_subnet_id" {
  value = aws_subnet.priv_subnet.id
}

output "public_subnet_1_id" {
  value = aws_subnet.pub_subnet-1.id
}

output "public_subnet_2_id" {
  value = aws_subnet.pub_subnet-2.id
}

output "priv_subnet_2_id" {
  value = aws_subnet.priv_subnet-2.id
}