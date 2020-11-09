#--------------------------------------------lambda-layer----------------------------------------------------

locals {

    layer_name  = "payments_layer.zip"

    layers_path = "${path.module}/lambda-layers/nodejs"
}

resource "null_resource" "build_lambda_layers" {
    triggers = {
        layer_build = md5(file("${local.layers_path}/package.json"))
    }

    provisioner "local-exec" {
        working_dir = local.layers_path
        command     = "npm install --production && cd ../ && zip -9 -r --quiet ${local.layer_name} *"
    }
}

resource "aws_lambda_layer_version" "lambda_layers" {
    filename         = "${local.layers_path}/../${local.layer_name}"
    source_code_hash = filebase64sha256("${local.layers_path}/../${local.layer_name}")
    layer_name       = var.layer_name
    description      = "joi: ^17.3.0, uuid: ^8.3.1"



    compatible_runtimes = ["nodejs12.x"]
    depends_on          = [null_resource.build_lambda_layers]
}

#--------------------------------------------lambda_createPayments----------------------------------------------------



data "archive_file" "lambda_createPayments" {
    type = "zip"
    source_file = "${path.module}/lambdas/payments/create/main.js"
    output_path = "${path.module}/lambdas/payments/create/main.js.zip"
}

resource "aws_lambda_function" "lambda_createPayments" {
    function_name    = var.function_name
    role             = aws_iam_role.lambda_exec_role.arn
    handler          = "main.handler"
    source_code_hash = filebase64sha256(data.archive_file.lambda_createPayments.output_path)
    timeout          = 6
      memory_size    = 128

    runtime = "nodejs12.x"
    layers        = [aws_lambda_layer_version.lambda_layers.arn]

    s3_bucket = var.bucket_name
    s3_key    = var.function_name


    environment {
        variables = {
            DYNAMODB_TABLE = aws_dynamodb_table.dynamo_table_payments.name
        }
    }
}


resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size       = 10
  event_source_arn = aws_sqs_queue.payment_create_queue.arn
  enabled          = true
  function_name    = aws_lambda_function.lambda_createPayments.arn
}

resource "aws_lambda_permission" "allows_sqs_to_trigger_lambda" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_createPayments.arn
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.payment_create_queue.arn
}



#-------------------------lambda-extractPayment----------------------------------------------------------------


# data "archive_file" "lambda_extractPayment" {
#     type = "zip"
#     source_file = "${path.module}/lambdas/payments/extractPayment/main.js"
#     output_path = "${path.module}/lambdas/payments/extractPayment/main.js.zip"
# }

# resource "aws_lambda_function" "lambda_extractPayment" {
#     function_name    = var.function_name_extract
#     role             = aws_iam_role.lambda_exec_role.arn
#     handler          = "main.handler"
#     source_code_hash = filebase64sha256(data.archive_file.lambda_extractPayment.output_path)
#     timeout          = 6
#     memory_size      = 128

#     s3_bucket = var.bucket_name
#     s3_key    = var.function_name_extract


#     runtime = "nodejs12.x"
#     layers        = [aws_lambda_layer_version.lambda_layers.arn]
# }

# resource "aws_lambda_event_source_mapping" "payment" {
#   event_source_arn  = aws_dynamodb_table.dynamo_table_payments.stream_arn
#   function_name     = aws_lambda_function.lambda_extractPayment.arn
#   starting_position = "LATEST"
# }

#-------------------------------------------lambda_validateRequest--------------------------------------------

data "archive_file" "lambda_validateRequest" {
    type = "zip"
    source_file = "${path.module}/lambdas/payments/validateRequest/main.js"
    output_path = "${path.module}/lambdas/payments/validateRequest/main.js.zip"
}

resource "aws_lambda_function" "lambda_validateRequest" {
    function_name    = var.function_name_validate
    role             = aws_iam_role.lambda_validateRequest.arn
    handler          = "main.handler"
    source_code_hash = filebase64sha256(data.archive_file.lambda_validateRequest.output_path)
    timeout          = 6
    memory_size      = 128

    s3_bucket = var.bucket_name
    s3_key    = var.function_name_validate


    runtime = "nodejs12.x"
    layers        = [aws_lambda_layer_version.lambda_layers.arn]


    environment {
        variables = {
            TOPIC_ARN = aws_sns_topic.payment.arn
        }
    }

}

resource "aws_lambda_permission" "apigw_lambda" {
    statement_id  = "AllowExecutionFromAPIGateway"
    action        = "lambda:InvokeFunction"
    function_name = var.function_name_validate
    principal     = "apigateway.amazonaws.com"
    source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*" 
}