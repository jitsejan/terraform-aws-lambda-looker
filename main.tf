# The AWS provider
provider "aws" {
  region = "${var.region}"
}

# Define the public bucket
resource "aws_s3_bucket" "bucket-lambda-deployments" {
  bucket = "dev-jwat"
  region = "${var.region}"
  acl    = "public-read"

  versioning = {
    enabled = true
  }

  tags = {
    Environment = "Development"
    Owner       = "Jitse-Jan"
  }
}

# Define the policy for the role
resource "aws_iam_role_policy" "policy-lambda" {
  name = "dev-jwat-policy-lambda"
  role = "${aws_iam_role.role-lambda.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ssm:GetParameter",
        "s3:PutObject",
        "s3:ListBucket",
        "s3:GetObject"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

# Define the role
resource "aws_iam_role" "role-lambda" {
  name        = "dev-jwat-role-lambda"
  description = "Role to execute all Lambda related tasks."

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

# Define the Lambda function
resource "aws_lambda_function" "lambda-function" {
  function_name = "dev-lambda-looker-upload"
  description   = "Lambda function for uploading a Looker view"
  handler       = "${var.handler}"
  runtime       = "${var.runtime}"

  filename = "sources/lambda-functions/looker-upload/lambda.zip"
  role     = "${aws_iam_role.role-lambda.arn}"

  tags = {
    Environment = "Development"
    Owner       = "Jitse-Jan"
  }
}

# Define the CloudWatch schedule
resource "aws_cloudwatch_event_rule" "cloudwatch-event-rule-midnight-run" {
  name                = "dev-cloudwatch-event-rule-midnight-run-looker-upload"
  description         = "Cloudwatch event rule to run every day at midnight for the Looker upload."
  schedule_expression = "${var.schedule_midnight}"
}

# Define the CloudWatch target
resource "aws_cloudwatch_event_target" "cloudwatch-event-target" {
  rule = "dev-cloudwatch-event-rule-midnight-run-looker-upload"
  arn  = "arn:aws:lambda:${var.region}:848373817713:function:dev-lambda-looker-upload"
}

# Define the Lambda permission to run Lambda from CloudWatch
resource "aws_lambda_permission" "lambda-permission-cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "dev-lambda-looker-upload"
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:events:${var.region}:848373817713:rule/dev-cloudwatch-event-rule-midnight-run-looker-upload"
}
