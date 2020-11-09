resource "aws_sqs_queue" "payment_create_queue" {
    name                      = "payment-create-queue"
    delay_seconds             = 1
    max_message_size          = 2048

    tags = {
      Environment = var.env
    }
}