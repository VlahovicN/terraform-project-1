resource "aws_lb" "terraform-alb" {
load_balancer_type = "application" 
security_groups = [var.alb_sg_id]
name = "terraform-alb"
subnets = var.subnets
enable_deletion_protection = true
}


resource "aws_lb_target_group" "ALB_TG" {
  name = "alb-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id
  deregistration_delay = 30
target_type = "instance"

health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2

}
}

resource "aws_lb_listener" "ALB_Listener" {
  load_balancer_arn = aws_lb.terraform-alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ALB_TG.arn
  }
  depends_on = [ aws_lb.terraform-alb ]
}
