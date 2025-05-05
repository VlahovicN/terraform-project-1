resource "aws_cloudwatch_metric_alarm" "asg_cpu_alarm" {
  alarm_name          = "cpu_alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  insufficient_data_actions = []
  ok_actions = [var.asg_action]
  dimensions = {
    AutoScalingGroupName = var.autoscaling_group
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [var.asg_action, var.sns_action]
}



resource "aws_cloudwatch_metric_alarm" "private_instance_cpu_alarm" {
  alarm_name = "priv_instance_cpu_alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 5
  metric_name  = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 60
  statistic = "Average"
  threshold = 70
  insufficient_data_actions = []
  alarm_actions = [var.sns_action]
  ok_actions = [var.asg_action]
  dimensions = {
    InstanceId = var.private_instance_id
  }
}


