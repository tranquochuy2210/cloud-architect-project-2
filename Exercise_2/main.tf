provider "aws" {
  region = var.aws_region
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Principal": {
            "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
    }]
}
EOF
}
resource "aws_iam_policy" "function_logging_policy" {
  name   = "function-logging-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "function_logging_policy_attachment" {
  role       = aws_iam_role.iam_for_lambda.id
  policy_arn = aws_iam_policy.function_logging_policy.arn
}


resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/example_lambda_function"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_lambda_function" "my_lambda_function" {
  function_name = "example_lambda_function"
  filename      = "./greet_lambda.zip" 
  handler       = "greet_lambda.lambda_handler" 
  depends_on    = [aws_cloudwatch_log_group.lambda_log_group]
  runtime       = "python3.8" 
  role          = aws_iam_role.iam_for_lambda.arn
  environment {
    variables = {
      greeting = "hello"
    }
  }
  logging_config {
    log_format = "JSON"
    log_group = "/aws/lambda/example_lambda_function"
  }
}