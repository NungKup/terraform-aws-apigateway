
resource "aws_api_gateway_api_key" "default" {
  for_each = var.enable_api_key ? var.api_key : {}

  name        = lookup(each.value, "name_api_key", "restapi-apikey")
  description = lookup(each.value, "description_api_key", "This API Key for API Gateway by Terraform")
  enabled     = lookup(each.value, "enabled_api_key", true)
  value       = lookup(each.value, "value_api_key", null)
}

resource "aws_api_gateway_usage_plan" "default" {
  for_each = var.enable_api_key ? var.api_key : {}

  name         = lookup(each.value, "name_usage_plan", "restapi-usage-plan")
  description  = lookup(each.value, "description_usage_plan", "This usage plan for API Gateway by Terraform")
  product_code = lookup(each.value, "product_code_usage_plan", "MYCODE")

  api_stages {
    api_id = var.api_id
    stage  = lookup(each.value, "stage", "")
  }

  quota_settings {
    limit  = 20
    offset = 2
    period = "WEEK"
  }

  throttle_settings {
    burst_limit = 5
    rate_limit  = 10
  }
}

resource "aws_api_gateway_usage_plan_key" "default" {
  for_each = var.enable_api_key ? var.api_key : {}

  key_id        = aws_api_gateway_api_key.default[each.key].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default[each.key].id
}

