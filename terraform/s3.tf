resource "aws_s3_bucket" "bucket" {
  bucket =  var.bucket_name
  acl    = "private"

  tags = {
    Name        = var.bucket_name
    Environment = var.env
  }
}

data "archive_file" "s3_validateRequest" {
    type = "zip"
    source_file = "${path.module}/lambdas/payments/validateRequest/main.js"
    output_path = "${path.module}/lambdas/payments/validateRequest/main.js.zip"
}
resource "aws_s3_bucket_object" "s3_validateRequest" {
  bucket = var.bucket_name
  key    = var.function_name_validate
  source = data.archive_file.s3_validateRequest.output_path


  etag = filemd5(data.archive_file.s3_validateRequest.output_path)
}

#--------------------------------s3_lambda_extractPayment---------------------------
data "archive_file" "s3_extractPayment" {
    type = "zip"
    source_file = "${path.module}/lambdas/payments/extractPayment/main.js"
    output_path = "${path.module}/lambdas/payments/extractPayment/main.js.zip"
}

resource "aws_s3_bucket_object" "s3_extractPayment" {
  bucket = var.bucket_name
  key    = var.function_name_extract
  source = data.archive_file.s3_extractPayment.output_path


  etag = filemd5(data.archive_file.s3_extractPayment.output_path)
}

#--------------------------------s3_lambda_createPayment---------------------------

data "archive_file" "s3_createPayment" {
    type = "zip"
    source_file = "${path.module}/lambdas/payments/create/main.js"
    output_path = "${path.module}/lambdas/payments/create/main.js.zip"
}

resource "aws_s3_bucket_object" "s3_createPayment" {
  bucket = var.bucket_name
  key    = var.function_name
  source = data.archive_file.s3_createPayment.output_path


  etag = filemd5(data.archive_file.s3_createPayment.output_path)
}