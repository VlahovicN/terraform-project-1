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



resource "aws_vpc" "new" {
  cidr_block = var.cidr
  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "pub_subnet" {
  vpc_id     = aws_vpc.new.id
  cidr_block = var.subnet_cidr
  map_public_ip_on_launch = true
  tags = {
    Name = "pub_subnet"
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
  subnet_id      = aws_subnet.pub_subnet.id
  route_table_id = aws_route_table.new_rt.id
}



resource "aws_security_group" "allow_ssh_and_http" {
  name        = "allow_ssh_and_http"
  description = "Allow ssh and http"
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


resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.allow_ssh_and_http.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_icmp" {
  security_group_id = aws_security_group.allow_ssh_and_http.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = -1
  ip_protocol = "icmp"
  to_port = -1
}


resource "aws_instance" "new_instance" {
  ami = var.ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.pub_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_ssh_and_http.id]

user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              echo "Hello from Nikola's Terraform Server 🚀" > /var/www/html/index.html
              systemctl start nginx
              systemctl enable nginx
              EOF

}



resource "aws_s3_bucket" "html_backup" {
  bucket = var.bucket_name
  force_destroy = true
  tags = {
    Name        = var.bucket_name
    Environment = "Dev"
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


