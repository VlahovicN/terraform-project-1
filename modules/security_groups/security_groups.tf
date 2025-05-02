##################################################
################ Security GROUPS #################




resource "aws_security_group" "autoscaling_security_group" {
  name        = "autoscaling_security_group"
  description = "autoscaling_security_group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "autoscaling_security_group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.autoscaling_security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}


resource "aws_security_group_rule" "allow_http_from_ALB_SG" {
  type = "ingress"
  security_group_id = aws_security_group.autoscaling_security_group.id
  from_port = 80
  to_port = 80
  protocol = "TCP"
  source_security_group_id = aws_security_group.ALB_SG.id
  
}


resource "aws_vpc_security_group_egress_rule" "allow_all_outbound_traffic" {
  security_group_id = aws_security_group.autoscaling_security_group.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = -1
}



resource "aws_security_group_rule" "allow_icmp_from_private_subnet_SG" {
  type = "ingress"
  security_group_id = aws_security_group.autoscaling_security_group.id
  from_port = -1
  to_port = -1
  protocol = "icmp"
  source_security_group_id = aws_security_group.priv_subnet_sg.id
}


########## Private Subnet Security Group #############


resource "aws_security_group" "priv_subnet_sg" {
  name = "priv_subnet_sg"
  vpc_id = var.vpc_id
  description = "allowing "

tags = {
  Name = "priv_subnet_sg"
}

}

resource "aws_security_group_rule" "allow_ssh_from_public_subnet" {
  type = "ingress"
  security_group_id = aws_security_group.priv_subnet_sg.id
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = aws_security_group.autoscaling_security_group.id
}

resource "aws_security_group_rule" "allow_icmp_from_public_subnet" {
  type = "ingress"
  security_group_id = aws_security_group.priv_subnet_sg.id
  from_port = -1
  to_port = -1
  protocol = "icmp"
  source_security_group_id = aws_security_group.autoscaling_security_group.id
}

resource "aws_security_group_rule" "outbound" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.priv_subnet_sg.id
  cidr_blocks = ["0.0.0.0/0"]
}


########## ALB Security GROUP ############


resource "aws_security_group" "ALB_SG" {
  name = "ALB_SG"
  vpc_id = var.vpc_id
  tags = {
    Name = "ALB_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_to_ALB" {
  security_group_id = aws_security_group.ALB_SG.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 80
  to_port = 80
  ip_protocol = "tcp"
}



resource "aws_security_group_rule" "alb_sg_allow_ssh_from_public_subnet" {
  security_group_id = aws_security_group.ALB_SG.id
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = aws_security_group.autoscaling_security_group.id
}

resource "aws_security_group_rule" "alb_sg_allow_icmp_from_public_subnet" {
  type = "ingress"
  security_group_id = aws_security_group.ALB_SG.id
  from_port = -1
  to_port = -1
  protocol = "icmp"
  source_security_group_id = aws_security_group.autoscaling_security_group.id
}

resource "aws_security_group_rule" "alb_sg_outbound" {
  type = "egress"
  security_group_id = aws_security_group.ALB_SG.id
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

