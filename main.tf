locals {
  name_default        = "terraform-${random_string.default.result}-mock"
  description_default = "terraform-${random_string.default.result}-mock"
}

resource "random_string" "default" {
  length  = 5
  special = false
  upper   = false
}

resource "aws_api_gateway_rest_api" "default" {
  for_each = var.enable_apigw ? var.apigw_name : null

  name                     = lookup(each.value, "name_api", "${local.name_default}-api-gateway")
  description              = lookup(each.value, "description_api", "${local.description_default} create API Gateway by Terraform")
  minimum_compression_size = lookup(each.value, "minimum_compression_size", -1)
  api_key_source           = lookup(each.value, "api_key_source", "HEADER")

  dynamic "endpoint_configuration" {
    for_each = var.apigw_name
    content {
      types            = lookup(each.value, "types", ["PRIVATE"])
      vpc_endpoint_ids = [each.value.types == ["PRIVATE"] ? data.aws_vpc_endpoint.api[each.key].id : null]
    }
  }
  tags = { Name = lookup(each.value, "name_api", "${local.name_default}-api-gateway") }
}

### Resource AWS API Gateway Policy
resource "aws_api_gateway_rest_api_policy" "default" {
  for_each = var.enable_apigw && var.enable_apigw_private ? var.apigw_name : null

  rest_api_id = aws_api_gateway_rest_api.default[each.key].id
  policy      = data.aws_iam_policy_document.apigw_policy[each.key].json
}

resource "aws_api_gateway_resource" "default" {
  for_each = var.enable_resource_path ? var.resource_path : {}

  rest_api_id = "%{~for v in aws_api_gateway_rest_api.default~}${~v.id~}%{~endfor~}"
  parent_id   = lookup(each.value, "parent_id", "%{~for v in aws_api_gateway_rest_api.default~}${~v.root_resource_id~}%{~endfor~}")
  path_part   = lookup(each.value, "path_part", "")

  depends_on = [
    aws_api_gateway_rest_api.default,
    aws_api_gateway_rest_api_policy.default
  ]
}
resource "aws_api_gateway_model" "default" {
  for_each = var.enable_model_count ? var.resource_path : null

  rest_api_id  = "%{~for v in aws_api_gateway_rest_api.default~}${~v.id~}%{~endfor~}"
  name         = lookup(each.value, "name_model", "")
  description  = lookup(each.value, "description_model", "")
  content_type = lookup(each.value, "content_type_model", "")

  schema = lookup(each.value, "model_schemas", jsonencode({ type = "object" }))

  depends_on = [
    aws_api_gateway_rest_api.default,
    aws_api_gateway_rest_api_policy.default
  ]
}

resource "aws_api_gateway_method" "default" {
  for_each = length(var.resource_path) > 0 ? var.resource_path : null

  rest_api_id          = "%{~for v in aws_api_gateway_rest_api.default~}${~v.id~}%{~endfor~}"
  resource_id          = "%{~for v in aws_api_gateway_resource.default~}${~v.id~}%{~endfor~}"
  http_method          = lookup(each.value, "http_method", "")
  authorization        = lookup(each.value, "authorization", "NONE")
  authorizer_id        = lookup(each.value, "authorizer_id", "%{~for i, v in aws_api_gateway_authorizer.default~}${~v.id~}%{~if i > 0~}v.id%{~else~}null%{~endif~}%{~endfor~}")
  authorization_scopes = lookup(each.value, "authorization_scopes", null)
  api_key_required     = lookup(each.value, "api_key_required", null)
  request_models       = lookup(each.value, "request_models", { "application/json" = "Empty" })
  request_validator_id = lookup(each.value, "request_validator_id", null)
  request_parameters   = lookup(each.value, "request_parameters", {})

  depends_on = [
    aws_api_gateway_rest_api.default,
    aws_api_gateway_rest_api_policy.default,
    aws_api_gateway_resource.default
  ]
}

resource "aws_api_gateway_integration" "default" {
  for_each = length(var.resource_path) > 0 ? var.resource_path : null

  rest_api_id             = "%{~for v in aws_api_gateway_rest_api.default~}${~v.id~}%{~endfor~}"
  resource_id             = "%{~for v in aws_api_gateway_resource.default~}${~v.id~}%{~endfor~}"
  http_method             = lookup(each.value, "http_method", "")
  integration_http_method = lookup(each.value, "integration_http_method", null)
  type                    = lookup(each.value, "integration_type", "AWS_PROXY")
  connection_type         = lookup(each.value, "integration_connection_type", "INTERNET")
  connection_id           = lookup(each.value, "integration_connection_id", each.value.integration_connection_type == "VPC_LINK" ? "%{~for v in aws_api_gateway_vpc_link.default~}${~v.id~}%{~endfor~}" : "")
  uri                     = lookup(each.value, "integration_uri", "")
  credentials             = lookup(each.value, "integration_credentials", "")
  request_parameters      = lookup(each.value, "integration_request_parameters", {})
  request_templates       = lookup(each.value, "integration_request_templates", {})
  passthrough_behavior    = lookup(each.value, "integration_passthrough_behavior", null)
  cache_key_parameters    = lookup(each.value, "integration_cache_key_parameters", [])
  cache_namespace         = lookup(each.value, "integration_cache_namespace", "%{~for v in aws_api_gateway_resource.default~}${~v.id~}%{~endfor~}")
  content_handling        = lookup(each.value, "integration_content_handling", null)
  timeout_milliseconds    = lookup(each.value, "integration_timeout_milliseconds", 29000)

  depends_on = [
    aws_api_gateway_rest_api.default,
    aws_api_gateway_rest_api_policy.default,
    aws_api_gateway_resource.default,
    aws_api_gateway_method.default
  ]
}

resource "aws_api_gateway_method_response" "default" {
  for_each = length(var.resource_path) > 0 ? var.method_response : null

  rest_api_id         = "%{~for v in aws_api_gateway_rest_api.default~}${~v.id~}%{~endfor~}"
  resource_id         = "%{~for v in aws_api_gateway_resource.default~}${~v.id~}%{~endfor~}"
  http_method         = aws_api_gateway_method.default[*].http_method
  status_code         = lookup(each.value, "status_code", {})                #"%{~for i, v in each.value.status_code~}${~v~}%{~if i < length(v)~}v%{~else~}200%{~endif~}%{~endfor~}" # Terraform Status 200,400,500
  response_models     = lookup(each.value, "method_response_models", {})     #"%{~for i, v in each.value.method_response_models~}${~v~}%{~if i < length(v)~}v%{~else~}{}%{~endif~}%{~endfor~}"     #
  response_parameters = lookup(each.value, "method_response_parameters", {}) #"%{~for i, v in each.value.method_response_parameters~}${~v~}%{~if i < length(v)~}v%{~else~}{}%{~endif~}%{~endfor~}" #

  depends_on = [
    aws_api_gateway_rest_api.default,
    aws_api_gateway_rest_api_policy.default,
    aws_api_gateway_resource.default,
    aws_api_gateway_method.default,
    aws_api_gateway_integration.default
  ]
}

resource "aws_api_gateway_integration_response" "default" {
  for_each = length(var.resource_path) > 0 ? var.method_response : null

  rest_api_id         = "%{~for v in aws_api_gateway_rest_api.default~}${~v.id~}%{~endfor~}"
  resource_id         = "%{~for v in aws_api_gateway_resource.default~}${~v.id~}%{~endfor~}"
  http_method         = aws_api_gateway_method.default[*].http_method
  status_code         = lookup(each.value, "status_code", {})
  selection_pattern   = lookup(each.value, "selection_pattern", null)
  response_parameters = lookup(each.value, "integration_response_parameters", {}) #"%{~for i, v in each.value.integration_response_parameters~}${~v~}%{~if i < length(v)~}v%{~else~}{}%{~endif~}%{~endfor~}"
  response_templates  = lookup(each.value, "integration_response_templates", {})  #"%{~for i, v in each.value.integration_response_templates~}${~v~}%{~if i < length(v)~}v%{~else~}{}%{~endif~}%{~endfor~}"
  content_handling    = lookup(each.value, "integration_content_handling", null)  #"%{~for i, v in each.value.integration_content_handling~}${~v~}%{~if i < length(v)~}v%{~else~}null%{~endif~}%{~endfor~}"

  depends_on = [
    aws_api_gateway_rest_api.default,
    aws_api_gateway_rest_api_policy.default,
    aws_api_gateway_resource.default,
    aws_api_gateway_method.default,
    aws_api_gateway_integration.default
  ]
}

#------------------------------- Start Option Method ------------------------------------#
resource "aws_api_gateway_method" "options_method" {
  for_each = var.enable_option_method ? var.resource_path : null

  rest_api_id   = "%{~for v in aws_api_gateway_rest_api.default~}${~v.id~}%{~endfor~}"
  resource_id   = "%{~for v in aws_api_gateway_resource.default~}${~v.id~}%{~endfor~}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options_200" {
  for_each = var.enable_option_method ? var.resource_path : null

  rest_api_id = "%{~for v in aws_api_gateway_rest_api.default~}${~v.id~}%{~endfor~}"
  resource_id = "%{~for v in aws_api_gateway_resource.default~}${~v.id~}%{~endfor~}"
  http_method = "%{~for v in aws_api_gateway_method.options_method~}${~v.http_method~}%{~endfor~}"
  status_code = "200"

  response_models = { "application/json" = "Empty" }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }

  depends_on = [aws_api_gateway_method.options_method]
}

resource "aws_api_gateway_integration" "options_integration" {
  for_each = var.enable_option_method ? var.resource_path : null

  rest_api_id          = "%{~for v in aws_api_gateway_rest_api.default~}${~v.id~}%{~endfor~}"
  resource_id          = "%{~for v in aws_api_gateway_resource.default~}${~v.id~}%{~endfor~}"
  http_method          = "%{~for v in aws_api_gateway_method.options_method~}${~v.http_method~}%{~endfor~}"
  cache_key_parameters = []
  cache_namespace      = "%{~for v in aws_api_gateway_resource.default~}${~v.id~}%{~endfor~}"
  passthrough_behavior = "NEVER"
  request_parameters   = {}
  type                 = "MOCK"
  content_handling     = "CONVERT_TO_TEXT"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  depends_on = [aws_api_gateway_method.options_method]
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  for_each = var.enable_option_method ? var.resource_path : null

  rest_api_id        = "%{~for v in aws_api_gateway_rest_api.default~}${~v.id~}%{~endfor~}"
  resource_id        = "%{~for v in aws_api_gateway_resource.default~}${~v.id~}%{~endfor~}"
  http_method        = "%{~for v in aws_api_gateway_method.options_method~}${~v.http_method~}%{~endfor~}"
  status_code        = "%{~for v in aws_api_gateway_method_response.options_200~}${~v.status_code~}%{~endfor~}"
  response_templates = { "application/json" = "" }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,DELETE,GET,HEAD,PATCH,POST,PUT'"
  }

  depends_on = [
    aws_api_gateway_method_response.options_200,
    aws_api_gateway_integration.options_integration,
  ]
}
#------------------------------- End Option Method ------------------------------------#
#------------------------------ Start VPC Link ------------------------------#
# Module      : Api Gateway VPC Link
# Description : Terraform module to create Api Gateway VPC Link resource on AWS.
resource "aws_api_gateway_vpc_link" "default" {
  for_each = var.enable_vpc_link ? var.vpc_link : null

  name        = lookup(each.value, "name_vpc_link", "${local.name_default}-vpc-link")
  description = lookup(each.value, "description_vpc_link", "${local.description_default} vpc link for API Gateway by Terraform")
  target_arns = lookup(each.value, "target_nlb_arns", "")
}
#------------------------------ End VPC Link ------------------------------#
#------------------------------ Start API Key ------------------------------#
# Module      : Api Gateway Api Key
# Description : Terraform module to create Api Gateway Api Key resource on AWS.
resource "aws_api_gateway_api_key" "default" {
  for_each = var.enable_api_key ? var.api_key : null

  name        = lookup(each.value, "name_api_key", "${local.name_default}-apikey")
  description = lookup(each.value, "description_api_key", "${local.description_default} API Key for API Gateway by Terraform")
  enabled     = lookup(each.value, "enabled_api_key", true)
  value       = lookup(each.value, "value_api_key", null)
}

resource "aws_api_gateway_usage_plan" "default" {
  for_each = var.enable_api_key ? var.api_key : null

  name         = lookup(each.value, "name_usage_plan", "${local.name_default}-usage-plan")
  description  = lookup(each.value, "description_usage_plan", "${local.description_default} usage plan for API Gateway by Terraform")
  product_code = lookup(each.value, "product_code_usage_plan", "MYCODE")

  api_stages {
    api_id = "%{~for v in aws_api_gateway_rest_api.default~}${~v.id~}%{~endfor~}"
    stage  = "%{~for v in aws_api_gateway_stage.stage_name~}${~v.stage_name~}%{~endfor~}"
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
  for_each = var.enable_api_key ? var.api_key : null

  key_id        = "%{~for v in aws_api_gateway_api_key.default~}${~v.id~}%{~endfor~}"
  key_type      = "API_KEY"
  usage_plan_id = "%{~for v in aws_api_gateway_usage_plan.default~}${~v.id~}%{~endfor~}"
}


#------------------------------ End API Key ------------------------------#
# # Resource AWS Api Gateway Client Certificate
# resource "aws_api_gateway_client_certificate" "default" {
#   count       = var.cert_enabled ? 1 : 0
#   description = var.cert_description
# }
# Module      : Api Gateway Authorizer
resource "aws_api_gateway_authorizer" "default" {
  for_each = var.enable_authorizer ? var.authorizer : null

  rest_api_id                      = "%{~for v in aws_api_gateway_rest_api.default~}${~v.id~}%{~endfor~}"
  name                             = lookup(each.value, "name_authorizer", "${local.name_default}-authorizer")
  authorizer_uri                   = lookup(each.value, "authorizer_uri", "")
  authorizer_credentials           = lookup(each.value, "authorizer_credentials", "")
  authorizer_result_ttl_in_seconds = lookup(each.value, "authorizer_result_ttl_in_seconds", 300)
  identity_source                  = lookup(each.value, "identity_source", "method.request.header.Authorization")
  type                             = lookup(each.value, "authorizer_type", "TOKEN")
  identity_validation_expression   = lookup(each.value, "identity_validation_expression", "")
  provider_arns                    = lookup(each.value, "authorizer_provider_arns", null)
}

# # Module      : Api Gateway Gateway Response
# # Description : Terraform module to create Api Gateway Gateway Response resource on AWS.
# resource "aws_api_gateway_gateway_response" "default" {
#   count         = var.gateway_response_count > 0 ? var.gateway_response_count : 0
#   rest_api_id   = aws_api_gateway_rest_api.default.*.id[0]
#   response_type = element(var.response_types, count.index)
#   status_code   = length(var.gateway_status_codes) > 0 ? element(var.gateway_status_codes, count.index) : ""

#   response_templates = length(var.gateway_response_templates) > 0 ? element(var.gateway_response_templates, count.index) : {}

#   response_parameters = length(var.gateway_response_parameters) > 0 ? element(var.gateway_response_parameters, count.index) : {}
# }

#################
resource "aws_api_gateway_deployment" "default" {
  for_each = var.enable_apigw && var.deployment_enabled ? var.stage_deploy : null

  rest_api_id       = "%{~for v in aws_api_gateway_rest_api.default~}${~v.id~}%{~endfor~}"
  stage_name        = lookup(each.value, "stage_name", "")
  description       = lookup(each.value, "deployment_description", "")
  stage_description = lookup(each.value, "stage_description", "")
  variables         = lookup(each.value, "stage_variables", "")
  depends_on        = [aws_api_gateway_method.default, aws_api_gateway_integration.default]
}
# # # Resource AWS Api Gateway Stage
resource "aws_api_gateway_stage" "stage_name" {
  for_each = var.enable_apigw && var.deployment_enabled ? var.stage_deploy : null

  rest_api_id           = "%{~for v in aws_api_gateway_rest_api.default~}${~v.id~}%{~endfor~}"
  deployment_id         = "%{~for v in aws_api_gateway_deployment.default~}${~v.id~}%{~endfor~}"
  stage_name            = lookup(each.value, "stage_name", "")
  cache_cluster_enabled = lookup(each.value, "cache_cluster_enabled", false)
  cache_cluster_size    = lookup(each.value, "cache_cluster_enabled", null)
  # client_certificate_id = length(var.client_certificate_ids) > 0 ? element(var.client_certificate_ids, count.index) : (var.cert_enabled ? aws_api_gateway_client_certificate.default.*.id[0] : "")
  description           = lookup(each.value, "stage_description", "")
  documentation_version = lookup(each.value, "documentation_version", null)
  variables             = lookup(each.value, "documentation_version", {})
  xray_tracing_enabled  = lookup(each.value, "documentation_version", false)

  dynamic "access_log_settings" {
    for_each = var.enable_access_log_setting && var.enable_apigw && var.deployment_enabled ? var.access_log_settings : []
    content {
      destination_arn = access_log_settings.value.destination_arn
      format          = access_log_settings.value.format
    }
  }
  # access_log_settings {
  #   destination_arn = element(var.destination_arns, count.index)
  #   format          = element(var.formats, count.index)
  # }
}
