variable "region" {
    default = "us-east-1"
}

variable "account_id" {
    default = "YOU_ACCONT_ID"
}

variable "function_name" {
    default = "lambda_createPayments"
}

variable "layer_name" {
    default = "lambda-layer"
}

variable "api_name" {
    default = "Api-Payments"
}

variable "env" {
    default = "dev"
}

variable "dbname" {
    default = "payments"
}

variable "read_capacity" {
    default = "5"
}

variable "write_capacity" {
    default = "5"
}

variable "function_name_extract" {
    default = "lambda_extractPayment"
}

variable "function_name_validate" {
    default = "lambda_validateRequest"
}

variable "payment_topic_name" {
    default = "payment-data-drop"
}

variable "bucket_name" {
    default = "payments-serverless"
}