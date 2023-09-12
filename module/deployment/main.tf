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

resource "aws_api_gateway_method_settings" "default" {
  for_each = var.enable_method_setting ? var.method_setting : {}

  rest_api_id = var.api_id
  stage_name  = try(each.value.stage_name, "")
  method_path = try(each.value.method_path, "")

  settings {
    logging_level          = "OFF"
    metrics_enabled        = true
    throttling_rate_limit  = "10000"
    throttling_burst_limit = "5000"
    caching_enabled        = false
  }
  depends_on = [
    aws_api_gateway_stage.default
  ]
}

resource "aws_api_gateway_domain_name" "default" {
  for_each = var.enable_domain_name ? var.domain_name : {}

  domain_name              = try(each.value.domain_name, "")
  regional_certificate_arn = try(each.value.regional_certificate_arn, "")

  endpoint_configuration {
    types = [
      "REGIONAL",
    ]
  }
}

resource "aws_api_gateway_base_path_mapping" "default" {
  for_each = var.enable_domain_name ? var.domain_name : {}

  api_id      = var.api_id
  stage_name  = try(each.value.stage_name, "")
  domain_name = aws_api_gateway_domain_name.default[each.key].domain_name
  base_path   = try(each.value.stage_name, "") #var.stage_name == "prod" || var.stage_name == "production" ? "" : var.stage_name
}


# output "state_name" {

# }
