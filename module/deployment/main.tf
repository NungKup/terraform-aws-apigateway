resource "aws_api_gateway_deployment" "default" {
  for_each = var.deploy

  rest_api_id = var.api_id
  stage_name  = try(each.value.stage_name, "")
  description = try(each.value.deployment_description, "")
  # stage_description = lookup(each.value, "stage_description", "")
  # variables         = lookup(each.value, "stage_variables", "")
  #   depends_on        = [aws_api_gateway_method.default, aws_api_gateway_integration.default]
}

resource "aws_api_gateway_stage" "default" {
  for_each = var.stage

  deployment_id         = aws_api_gateway_deployment.default[lookup(each.value, "deployment_id", "")].id
  rest_api_id           = var.api_id
  stage_name            = try(each.value.stage_name, "")
  cache_cluster_size    = try(each.value.stage_name, "") == "production" ? 0.5 : null
  cache_cluster_enabled = try(each.value.stage_name, "") == "production" ? true : false

  dynamic "access_log_settings" {
    for_each = var.enable_stage_log ? var.stage.access_log_settings : {}

    content {
      destination_arn = try(access_log_settings.value.destination_arn, "")
      format = jsonencode(
        {
          caller          = "$context.identity.caller"
          httpMethod      = "$context.httpMethod"
          httpUserAgent   = "$context.identity.userAgent"
          ip              = "$context.identity.sourceIp"
          keywordPlatform = "$context.requestOverride.querystring.platform"
          keywordSearch   = "$context.requestOverride.querystring.q"
          protocol        = "$context.protocol"
          requestId       = "$context.requestId"
          requestTime     = "$context.requestTime"
          resourcePath    = "$context.resourcePath"
          responseLength  = "$context.responseLength"
          status          = "$context.status"
          user            = "$context.identity.user"
        }
      )
    }
  }
  depends_on = [aws_api_gateway_deployment.default]
}
