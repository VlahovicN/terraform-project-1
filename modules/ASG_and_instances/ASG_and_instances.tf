
########### AUTO SCALING GROUP ##############

resource "aws_launch_template" "template" {
  image_id = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [var.autoscaling_sg_id]
  key_name = var.key_name
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
  name = "my-first-asg"
  target_group_arns = var.target_group
  launch_template {
    id = aws_launch_template.template.id
    version = "$Latest"
  }
  vpc_zone_identifier = var.public_subnet_ids
  health_check_type = "ELB"
  health_check_grace_period = 300
  tag {
    key = "Name"
    value = "my-instance"
    propagate_at_launch = true
  }
}


resource "aws_autoscaling_policy" "CPU_Policy" {
  name = "CPU_Policy"
  policy_type = "SimpleScaling"
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = 1
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.autoscale.name
}


#############  PRIVATE INSTANCE  ###############

resource "aws_instance" "private_instance" {
  ami = var.ami
  subnet_id = var.priv_subnet_id
  vpc_security_group_ids = [var.priv_subnet_sg]
  instance_type = var.instance_type
  key_name = var.key_name

tags = {
  Name = "Private-Instance"
}

user_data = <<-EOF
  #!/bin/bash
  mkfs -t ext4 /dev/xvdh
  mkdir /data
  mount /dev/xvdh /data
  echo "/dev/xvdh /data ext4 defaults,nofail 0 2" >> /etc/fstab
EOF

}



######## EBS #########

resource "aws_ebs_volume" "ebs_for_private_ec2" {
  availability_zone = "us-east-1a"
  size              = 30
  type = "gp3"
  tags = {
    Name = "priv_ec2_ebs"
  }
}

resource "aws_volume_attachment" "priv_ebs_attach" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ebs_for_private_ec2.id
  instance_id = aws_instance.private_instance.id
  depends_on = [ aws_instance.private_instance, aws_ebs_volume.ebs_for_private_ec2 ]
}


