output "autoscaling_sg_id" {
  value = aws_security_group.autoscaling_security_group.id
}

output "priv_subnet_sg_id" {
  value = aws_security_group.priv_subnet_sg.id
}

output "alb_sg_id" {
  value = aws_security_group.ALB_SG.id
}

output "rds_sg" {
  value = aws_security_group.rds_sg.id
}

output "efs_sg" {
  value = aws_security_group.efs_sg.id
}