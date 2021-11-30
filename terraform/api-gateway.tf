resource "aws_apigatewayv2_api" "redirect-api" {
  name = "example-redirect-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "redirect-api-integration" {
  api_id = aws_apigatewayv2_api.redirect-api.id
  integration_type = "AWS_PROXY"

  connection_type = "INTERNET"
  description = "Route to redirect Lambda"
  integration_method = "POST"
  integration_uri = aws_lambda_function.redirect-lambda-function.invoke_arn
}

resource "aws_apigatewayv2_route" "redirect-api-route" {
  api_id = aws_apigatewayv2_api.redirect-api.id
  route_key = "GET /redirect/{proxy+}"
  target = "integrations/${aws_apigatewayv2_integration.redirect-api-integration.id}"
}

# Set up a default stage and enable auto-deploy plus some extremely aggressive rate limiting (not expecting lots of traffic)
resource "aws_apigatewayv2_stage" "redirect-api-default-stage" {
  api_id = aws_apigatewayv2_api.redirect-api.id
  name = "default"
  auto_deploy = true  # Changes to API will be auto-deployed to default stage

  # Aggressive throttling since this is just a demo-- you can modify if you need to allow more traffic
  default_route_settings {
    throttling_burst_limit = 2
    throttling_rate_limit = 2
  }
}

output "invoke_url" {
  value = "Paste this in your browser and replace <site_name> with something like youtube or google: ${aws_apigatewayv2_stage.redirect-api-default-stage.invoke_url}/redirect/<site_name>"
}