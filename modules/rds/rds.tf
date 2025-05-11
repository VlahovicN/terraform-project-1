resource "aws_db_instance" "default" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  password = var.password
  username = var.username
  instance_class       = "db.t3.micro"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  vpc_security_group_ids = [var.rds_sg]
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.db_subnet.name
  storage_type = "gp2"
  identifier = "rds-mysql-demo"
  deletion_protection = false
  backup_retention_period = 0
  multi_az = false
}


resource "aws_db_subnet_group" "db_subnet" {
  name       = "db_subnet"
  subnet_ids = var.db_subnets
  tags = {
    Name = "My DB subnet group"
  }
}