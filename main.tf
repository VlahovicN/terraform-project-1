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


resource "aws_instance" "new_instance" {
  ami = var.ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.pub_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_ssh_and_http.id]
}