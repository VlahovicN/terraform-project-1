terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.96.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

################################  VPC and networking ###########################################

resource "aws_vpc" "new" {
  cidr_block = var.cidr
  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "pub_subnet-1" {
  vpc_id     = aws_vpc.new.id
  cidr_block = var.subnet1_cidr
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
    Name = "pub_subnet-1"
  }
}


resource "aws_subnet" "pub_subnet-2" {
  vpc_id     = aws_vpc.new.id
  cidr_block = var.subnet2_cidr
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
  tags = {
    Name = "pub-subnet-2"
  }
}

resource "aws_internet_gateway" "new_gw" {
  vpc_id = aws_vpc.new.id

  tags = {
    Name = "main"
  }
}


resource "aws_route_table" "new_rt" {
  vpc_id = aws_vpc.new.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.new_gw.id
  }
  tags = {
    Name = "new_rt"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.pub_subnet-1.id
  route_table_id = aws_route_table.new_rt.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.pub_subnet-2.id
  route_table_id = aws_route_table.new_rt.id
}

###################### Security group and rules #####################################

resource "aws_security_group" "allow_ssh_and_http" {
  name        = "allow_ssh_and_http"
  description = "Allow inbound ssh and http, and icmp for outbound"
  vpc_id      = aws_vpc.new.id

  tags = {
    Name = "allow_ssh_http"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_ssh_and_http.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}


resource "aws_security_group_rule" "allow_http_from_ALB_SG" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "TCP"
  source_security_group_id = aws_security_group.ALB_SG.id
  security_group_id = aws_security_group.allow_ssh_and_http.id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound_traffic" {
  security_group_id = aws_security_group.allow_ssh_and_http.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = -1
}


resource "aws_security_group_rule" "allow_icmp_from_private_subnet_SG" {
  type = "ingress"
  from_port = -1
  to_port = -1
  protocol = "icmp"
  security_group_id = aws_security_group.allow_ssh_and_http.id
  source_security_group_id = aws_security_group.priv_subnet_sg.id
}


######## AUTO SCALING + ELB #####################


resource "aws_launch_template" "template" {
  image_id = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [ aws_security_group.allow_ssh_and_http.id ]
  key_name = aws_key_pair.instance_ssh_key.id
  user_data = base64encode(<<-EOF
              #!/bin/bash
              
              rm -rf /var/lib/apt/lists/*
              apt-get update --allow-releaseinfo-change -y
              apt-get install -y nginx
              
              echo "Hello from Nikola's Terraform Server 🚀" > /var/www/html/index.html
              
              systemctl start nginx
              systemctl enable nginx
EOF
)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "my-instance"
    }
  }
}


resource "aws_autoscaling_group" "autoscale" {
  max_size = 3
  min_size = 1
  desired_capacity = 2
  target_group_arns = [aws_lb_target_group.ALB_TG.arn]
  launch_template {
    id = aws_launch_template.template.id
    version = "$Latest"
  }
  vpc_zone_identifier = [aws_subnet.pub_subnet-1.id, aws_subnet.pub_subnet-2.id]
  health_check_type = "ELB"
  health_check_grace_period = 300
  tag {
    key = "Name"
    value = "my-instance"
    propagate_at_launch = true
  }
}


resource "aws_security_group" "ALB_SG" {
  name = "ALB_SG"
  vpc_id = aws_vpc.new.id
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

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound_traffic_from_ALB" {
  security_group_id = aws_security_group.ALB_SG.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_lb" "terraform-alb" {
 load_balancer_type = "application" 
 security_groups = [aws_security_group.ALB_SG.id]
name = "terraform-alb"
subnets = [aws_subnet.pub_subnet-1.id, aws_subnet.pub_subnet-2.id]
enable_deletion_protection = true
}


resource "aws_lb_target_group" "ALB_TG" {
  name = "alb-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.new.id
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

########### S3 Bucket ###########

resource "aws_s3_bucket" "html_backup" {
  bucket = var.bucket_name
  force_destroy = true
  tags = {
    Name        = var.bucket_name
  }
}


resource "aws_s3_bucket_policy" "public_access_policy" {
  bucket = aws_s3_bucket.html_backup.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.html_backup.arn}/*",  # Allow access to all objects within the bucket
      },
    ],
  })
  depends_on = [ aws_s3_bucket_public_access_block.allow_public ]
}

resource "aws_s3_object" "add_html_file" {
  bucket = aws_s3_bucket.html_backup.id
  key = "backup/index.html"
  source = "/home/nikola/terraform-project-1/index.html"
  depends_on = [ aws_s3_bucket.html_backup ]
  content_type = "text/html"
}



resource "aws_s3_bucket_public_access_block" "allow_public" {
  bucket = aws_s3_bucket.html_backup.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


########## Adding new subnet, new ec2 instance, nat gateway, and allowing communication ###########


resource "aws_subnet" "priv_subnet" {
  vpc_id     = aws_vpc.new.id
  cidr_block = var.priv_subnet_cidr
  tags = {
    Name = "priv_subnet"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.pub_subnet-1.id

tags = {
  Name = "My_NAT_GW"
}
depends_on = [ aws_internet_gateway.new_gw ]
}

resource "aws_route_table" "priv_rt" {
  vpc_id = aws_vpc.new.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
}
  tags = {
    Name = "priv_rt"
  }
}

resource "aws_route_table_association" "b" {
  subnet_id = aws_subnet.priv_subnet.id
  route_table_id = aws_route_table.priv_rt.id
}


resource "aws_security_group" "priv_subnet_sg" {
  name = "priv_subnet_sg"
  vpc_id = aws_vpc.new.id
  description = "allowing "

tags = {
  Name = "priv_subnet_sg"
}

}

resource "aws_security_group_rule" "allow_ssh_from_public_subnet" {
  security_group_id = aws_security_group.priv_subnet_sg.id
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = aws_security_group.allow_ssh_and_http.id
}

resource "aws_security_group_rule" "allow_icmp_from_public_subnet" {
  type = "ingress"
  security_group_id = aws_security_group.priv_subnet_sg.id
  from_port = -1
  to_port = -1
  protocol = "icmp"
  source_security_group_id = aws_security_group.allow_ssh_and_http.id
}

resource "aws_security_group_rule" "outbound" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.priv_subnet_sg.id
  cidr_blocks = ["0.0.0.0/0"]
}


resource "aws_instance" "private_instance" {
  ami = var.ami
  subnet_id = aws_subnet.priv_subnet.id
  vpc_security_group_ids = [aws_security_group.priv_subnet_sg.id]
  instance_type = var.instance_type
  key_name = aws_key_pair.instance_ssh_key.id

tags = {
  Name = "Private-Instance"
}

}


########## KEY-PAIR ##########################

resource "aws_key_pair" "instance_ssh_key" {
  key_name   = "instance_access_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCZ2AQNT+9+l67CZGYNc5QhFy6J02YKYB+XRIkrYQmfef4hKbGb7Z//bWRAag+lHozc2AV+LtZ3fmYt0TOecWnFLCtWFZQrQHoQwMWWJAJXIgFS06K2xZbNAxdCbnhi8JEHUeGWlfWm0Xg0IZoUD/8SQSgYL1nbKBbklaq6InLJQw4u1c8zL9I4VHMbnO37/w3fUon6HBB0pUEd4wTdVdxU7LBvWCmysHvfV0j4U5l7JQYKT+aGUAzCKcbRlpMaTgbQT5FAUmeHa4Nla4BD4BpDpwN5CPIhHUxfG6oV3YOatPiiiWvkRW92VSdzAtKJ6RW88So/mTK/FNqfo0dlhxxx nikola@Nikola"
}