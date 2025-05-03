resource "aws_vpc" "new" {
  cidr_block = var.cidr
  tags = {
    Name = "new"
  }
}


###########   SUBNETS   ###############

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


resource "aws_subnet" "priv_subnet" {
  vpc_id     = aws_vpc.new.id
  cidr_block = var.priv_subnet_cidr
  availability_zone = "us-east-1a"
  tags = {
    Name = "priv_subnet"
  }
}

resource "aws_subnet" "priv_subnet-2" {
  vpc_id = aws_vpc.new.id
  cidr_block = var.priv_subnet_2_cidr
  availability_zone = "us-east-1b"
  tags = {
    Name = "priv_subnet_1"
  }
}


############ VPC INTERNET GATEWAY ##############

resource "aws_internet_gateway" "new_gw" {
  vpc_id = aws_vpc.new.id

  tags = {
    Name = "main"
  }
}


################### ROUTE TABLES and associations #####################

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



resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.pub_subnet-1.id
  route_table_id = aws_route_table.new_rt.id
}



resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.pub_subnet-2.id
  route_table_id = aws_route_table.new_rt.id
}


resource "aws_route_table_association" "c" {
  subnet_id = aws_subnet.priv_subnet.id
  route_table_id = aws_route_table.priv_rt.id
}

resource "aws_route_table_association" "d" {
  subnet_id = aws_subnet.priv_subnet-2.id
  route_table_id = aws_route_table.priv_rt.id
}


################ NAT GATEWAY ######################

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.pub_subnet-1.id

tags = {
  Name = "My_NAT_GW"
}
depends_on = [ aws_internet_gateway.new_gw ]
}

################# Elastic IP for NAT GW ###################

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}
