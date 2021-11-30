# IAM role for the redirect Lambda
resource "aws_iam_role" "redirect-lambda-role" {
  name = "redirect-lambda-role"

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

# Attach a basic Lambda execution policy to the above role. Just for Cloudwatch logging
resource "aws_iam_role_policy_attachment" "redirect-lambda-role-attach1" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role = aws_iam_role.redirect-lambda-role.id
}

# Zip up the code so we can upload it to AWS Lambda
data "archive_file" "redirect-lambda-code-zip" {
  output_path = "${path.module}/lambda_code/lambda_redirect.zip"
  type = "zip"
  source_file = "${path.module}/lambda_code/lambda_redirect.py"
}

# Create the actual redirect Lambda function
resource "aws_lambda_function" "redirect-lambda-function" {
  function_name = "redirect-lambda-example"
  handler = "lambda_redirect.lambda_handler"
  role = aws_iam_role.redirect-lambda-role.arn
  runtime = "python3.8"

  filename = data.archive_file.redirect-lambda-code-zip.output_path
  source_code_hash = filemd5(data.archive_file.redirect-lambda-code-zip.output_path)

  tags = {
    Name = "redirect-lambda-function"
  }
}

# Allow AWS API Gateway to invoke the Lambda function
resource "aws_lambda_permission" "redirect-lambda-permission" {
  statement_id = "AllowAPIGateway-RedirectLambda"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.redirect-lambda-function.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.redirect-api.execution_arn}/*/*"
}



















