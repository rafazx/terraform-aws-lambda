
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_role_sqs_policy" {
    name = "AllowSQSPermissions"
    role = aws_iam_role.lambda_exec_role.id
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sqs:ChangeMessageVisibility",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ReceiveMessage"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "lambda_role_dynamo_policy_role" {
    name = "AllowDynamoPermissions"
    role = aws_iam_role.lambda_exec_role.id
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}



resource "aws_iam_role_policy" "lambda_role_logs_policy_role" {
    name = "LambdaRolePolicy"
    role = aws_iam_role.lambda_exec_role.id
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}




#------------------------------------lambda-validateRequest---------------------------------


resource "aws_iam_role" "lambda_validateRequest" {
   assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow" 
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "lambda_validateRequest" {
  role       = aws_iam_role.lambda_validateRequest.name
  policy_arn = aws_iam_policy.lambda_validateRequest.arn
}

resource "aws_iam_policy" "lambda_validateRequest" {
  policy = data.aws_iam_policy_document.lambda_validateRequest.json
}

data "aws_iam_policy_document" "lambda_validateRequest" {
    statement {
        sid       = "AllowSNSPermissions"
        effect    = "Allow"
        resources = ["*"]

        actions   = [
            "SNS:*"
            ]
    }

    statement {
        sid       = "AllowInvokingLambdas"
        effect    = "Allow"
        resources = ["arn:aws:lambda:*:*:function:*"]
        actions   = ["lambda:InvokeFunction"]
    }
}

resource "aws_iam_role_policy" "lambda_role_logs_policy" {
    name = "LambdaRolePolicy"
    role = aws_iam_role.lambda_validateRequest.id
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


#-----------------------------SNS-SQS----------------------------------------


resource "aws_sqs_queue_policy" "results_updates_queue_policy" {
    queue_url = aws_sqs_queue.payment_create_queue.id

    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.payment_create_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.payment.arn}"
        }
      }
    }
  ]
}
POLICY
}