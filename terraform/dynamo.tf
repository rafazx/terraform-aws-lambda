resource "aws_dynamodb_table" "dynamo_table_payments" {
    name             = var.dbname
    read_capacity    = var.read_capacity
    write_capacity   = var.write_capacity
    stream_enabled   = true
    stream_view_type = "NEW_AND_OLD_IMAGES"
    hash_key         = "paymentId"

    attribute {
        name = "paymentId"
        type = "S"
    }

    tags = {
        name        = var.dbname
        Environment = var.env
    }
}
