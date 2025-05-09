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







########### CloudWatch Dashboards #############


resource "aws_cloudwatch_dashboard" "asg_cpu_utilization_dashboard" {
  dashboard_name = "asg-cpu-utilization"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x    = 0,
        y    = 0,
        width  = 24,
        height = 6,
        properties = {
          view     = "timeSeries",
          stacked  = false,
          region   = "us-east-1",
          title    = "ASG Average CPU Utilization",
          metrics  = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "AutoScalingGroupName",
              "${var.autoscaling_group}"
            ]
          ],
          period = 300,
          stat   = "Average"
        }
      }
    ]
  })
}



resource "aws_cloudwatch_dashboard" "priv_instance_cpu_utilization_dashboard" {
  dashboard_name = "priv_instance_cpu-utilization"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x    = 0,
        y    = 0,
        width  = 24,
        height = 6,
        properties = {
          view     = "timeSeries",
          stacked  = false,
          region   = "us-east-1",
          title    = "Private Instance Average CPU Utilization",
          metrics  = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              "${var.private_instance_id}"
            ]
          ],
          period = 300,
          stat   = "Average"
        }
      }
    ]
  })
}




resource "aws_cloudwatch_dashboard" "priv_instance_memory_dashboard" {
  dashboard_name = "priv_instance_memory-utilization"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x    = 0,
        y    = 0,
        width  = 24,
        height = 6,
        properties = {
          view     = "timeSeries",
          stacked  = false,
          region   = "us-east-1",
          title    = "Private Instance Memory Utilization",
          metrics  = [
            [
              "AWS/EC2",
              "mem_used",
              "InstanceId",
              "${var.private_instance_id}"
            ]
          ],
          period = 300,
          stat   = "Average"
        }
      }
    ]
  })
}