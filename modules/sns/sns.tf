resource "aws_sns_topic" "alarm-topic" {
  name = "alarm-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alarm-topic.arn
  protocol = "email"
  endpoint = "nikola.vlahovic318@gmail.com"
}