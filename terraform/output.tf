output "lambda_createPayments_url" {
  value = aws_lambda_function.lambda_createPayments.invoke_arn
}

output "api_url" {
  value = aws_api_gateway_deployment.apiDeployment.invoke_url
}

output "sqs_url" {
  value = aws_sqs_queue.payment_create_queue.id
}