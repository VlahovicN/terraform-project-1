########## KEY-PAIR ##########################

resource "aws_key_pair" "instance_ssh_key" {
  key_name   = "instance_access_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCZ2AQNT+9+l67CZGYNc5QhFy6J02YKYB+XRIkrYQmfef4hKbGb7Z//bWRAag+lHozc2AV+LtZ3fmYt0TOecWnFLCtWFZQrQHoQwMWWJAJXIgFS06K2xZbNAxdCbnhi8JEHUeGWlfWm0Xg0IZoUD/8SQSgYL1nbKBbklaq6InLJQw4u1c8zL9I4VHMbnO37/w3fUon6HBB0pUEd4wTdVdxU7LBvWCmysHvfV0j4U5l7JQYKT+aGUAzCKcbRlpMaTgbQT5FAUmeHa4Nla4BD4BpDpwN5CPIhHUxfG6oV3YOatPiiiWvkRW92VSdzAtKJ6RW88So/mTK/FNqfo0dlhxxx nikola@Nikola"
}
