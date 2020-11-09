resource "aws_sns_topic" "payment" {
    name         = var.payment_topic_name
    display_name = "Payment Data"
}

resource "aws_sns_topic_subscription" "payment" {
  topic_arn = aws_sns_topic.payment.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.payment_create_queue.arn
}