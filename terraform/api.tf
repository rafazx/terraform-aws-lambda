resource "aws_api_gateway_rest_api" "api" {
    name = var.api_name
}

resource "aws_api_gateway_resource" "resource" {
    path_part   = "api"
    parent_id   = aws_api_gateway_rest_api.api.root_resource_id
    rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "apiMethod" {
    rest_api_id   = aws_api_gateway_rest_api.api.id
    resource_id   = aws_api_gateway_resource.resource.id
    http_method   = "ANY"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "apiIntegration" {
    rest_api_id             = aws_api_gateway_rest_api.api.id
    resource_id             = aws_api_gateway_method.apiMethod.resource_id
    http_method             = aws_api_gateway_method.apiMethod.http_method
    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = aws_lambda_function.lambda_validateRequest.invoke_arn
}

resource "aws_api_gateway_deployment" "apiDeployment" {
    rest_api_id = aws_api_gateway_rest_api.api.id
    stage_name  = var.env
    depends_on  = [aws_api_gateway_integration.apiIntegration]
}
