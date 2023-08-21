resource "aws_api_gateway_deployment" "default" {
  for_each = var.deploy

  rest_api_id       = var.api_id
  stage_name        = lookup(each.value, "stage_name", "")
  description       = lookup(each.value, "deployment_description", "")
  stage_description = lookup(each.value, "stage_description", "")
  variables         = lookup(each.value, "stage_variables", "")
  #   depends_on        = [aws_api_gateway_method.default, aws_api_gateway_integration.default]
}

resource "aws_api_gateway_stage" "default" {
  for_each      = var.stage
  deployment_id = aws_api_gateway_deployment.default[lookup(each.value, "deployment_id", "")].id
  rest_api_id   = var.api_id
  stage_name    = lookup(each.value, "stage_name", "")
}
