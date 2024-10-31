# Set AWS Region for the lambda fucntion
provider "aws" {
  region = "eu-west-2"

}

# Create an IAM role for the lambda function
resource "aws_iam_role" "lambda_role" {
  name               = "Lambda_Function_Role"
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

# Create an IAM policy for managing aws lambda role
resource "aws_iam_policy" "iam_policy_for_lambda" {
  name   = "aws_iam_policy_for_terraform_aws_lambda_role"
  path   = "/"
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
                "Resource": "arn:aws:logs:*:*:*",
                "Effect": "Allow"
            }
        ]
    }
    EOF
}

# Attach the IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

# Create a zip file of the python code, ready to upload to Lambda
data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/python/"
  output_path = "${path.module}/python/hello_python.zip"
}

# Create the lambda function
resource "aws_lambda_function" "terraform_lambda_function" {
  filename      = "${path.module}/python/hello_python.zip"
  function_name = "Terraform_Lambda_Function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.12"
  depends_on    = [aws_iam_role_policy_attachment.attach_iam_policy_to_role]
}