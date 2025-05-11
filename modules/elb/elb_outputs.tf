output "terraform-alb_dns_name" {
  value = aws_lb.terraform-alb.dns_name
}

output "target_group" {
  value = [aws_lb_target_group.ALB_TG.arn]
}

