resource "aws_api_gateway_method" "default" {
  for_each = var.request_config

  rest_api_id          = lookup(each.value, "rest_api_id", var.api_id)
  resource_id          = lookup(each.value, "resource_id", var.resource_id)
  http_method          = lookup(each.value, "http_method", "")
  authorization        = lookup(each.value, "authorization", "NONE")
  authorizer_id        = lookup(each.value, "authorizer_id", var.api_authorizer_id == null ? null : var.api_authorizer_id)
  authorization_scopes = lookup(each.value, "authorization_scopes", null)
  api_key_required     = lookup(each.value, "api_key_required", null)
  request_models       = lookup(each.value, "request_models", { "application/json" = "Empty" })
  request_validator_id = lookup(each.value, "request_validator_id", null)
  request_parameters   = lookup(each.value, "request_parameters", {})
}

resource "aws_api_gateway_integration" "default" {
  for_each = var.request_config

  rest_api_id             = lookup(each.value, "rest_api_id", var.api_id)
  resource_id             = lookup(each.value, "resource_id", var.resource_id)
  http_method             = lookup(each.value, "http_method", "")
  integration_http_method = lookup(each.value, "integration_http_method", null)
  type                    = lookup(each.value, "integration_type", "AWS_PROXY")
  connection_type         = lookup(each.value, "integration_connection_type", "INTERNET")
  connection_id           = each.value.integration_connection_type == "VPC_LINK" ? each.value.connection_id : ""
  uri                     = lookup(each.value, "integration_uri", "")
  credentials             = lookup(each.value, "integration_credentials", "")
  request_parameters      = lookup(each.value, "integration_request_parameters", {})
  request_templates       = lookup(each.value, "integration_request_templates", {})
  passthrough_behavior    = lookup(each.value, "integration_passthrough_behavior", null)
  cache_key_parameters    = lookup(each.value, "integration_cache_key_parameters", [])
  cache_namespace         = lookup(each.value, "integration_cache_namespace", "") #"%{~for v in aws_api_gateway_resource.default~}${~v.id~}%{~endfor~}"
  content_handling        = lookup(each.value, "integration_content_handling", null)
  timeout_milliseconds    = lookup(each.value, "integration_timeout_milliseconds", 29000)
}

resource "aws_api_gateway_method_response" "default" {
  for_each = var.response_config

  rest_api_id         = lookup(each.value, "rest_api_id", var.api_id)
  resource_id         = lookup(each.value, "resource_id", var.resource_id)
  http_method         = aws_api_gateway_method.default[var.request_config.key].http_method
  status_code         = lookup(each.value, "status_code", {})                #"%{~for i, v in each.value.status_code~}${~v~}%{~if i < length(v)~}v%{~else~}200%{~endif~}%{~endfor~}" # Terraform Status 200,400,500
  response_models     = lookup(each.value, "method_response_models", {})     #"%{~for i, v in each.value.method_response_models~}${~v~}%{~if i < length(v)~}v%{~else~}{}%{~endif~}%{~endfor~}"     #
  response_parameters = lookup(each.value, "method_response_parameters", {}) #"%{~for i, v in each.value.method_response_parameters~}${~v~}%{~if i < length(v)~}v%{~else~}{}%{~endif~}%{~endfor~}" #
}

resource "aws_api_gateway_integration_response" "default" {
  for_each = var.response_config

  rest_api_id         = lookup(each.value, "rest_api_id", var.api_id)
  resource_id         = lookup(each.value, "resource_id", var.resource_id)
  http_method         = aws_api_gateway_method.default[var.request_config.key].http_method
  status_code         = lookup(each.value, "status_code", {})
  selection_pattern   = lookup(each.value, "selection_pattern", null)
  response_parameters = lookup(each.value, "integration_response_parameters", {}) #"%{~for i, v in each.value.integration_response_parameters~}${~v~}%{~if i < length(v)~}v%{~else~}{}%{~endif~}%{~endfor~}"
  response_templates  = lookup(each.value, "integration_response_templates", {})  #"%{~for i, v in each.value.integration_response_templates~}${~v~}%{~if i < length(v)~}v%{~else~}{}%{~endif~}%{~endfor~}"
  content_handling    = lookup(each.value, "integration_content_handling", null)  #"%{~for i, v in each.value.integration_content_handling~}${~v~}%{~if i < length(v)~}v%{~else~}null%{~endif~}%{~endfor~}"
}

### !!!! Option !!!!
# resource "aws_api_gateway_method" "options_method" {
#   for_each = var.enable_option_method ? var.request_config : {}

#   rest_api_id   = lookup(each.value, "rest_api_id", var.api_id)
#   resource_id   = lookup(each.value, "resource_id", var.resource_id)
#   http_method   = "OPTIONS"
#   authorization = "NONE"
# }
# resource "aws_api_gateway_method_response" "options_200" {
#   for_each = var.enable_option_method ? var.request_config : {}

#   rest_api_id = lookup(each.value, "rest_api_id", var.api_id)
#   resource_id = lookup(each.value, "resource_id", var.resource_id)
#   http_method = aws_api_gateway_method.options_method[each.key].http_method
#   status_code = "200"

#   response_models = { "application/json" = "Empty" }

#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Origin"  = true
#     "method.response.header.Access-Control-Allow-Headers" = true
#     "method.response.header.Access-Control-Allow-Methods" = true
#   }

# }
# resource "aws_api_gateway_integration" "options_integration" {
#   for_each = var.enable_option_method ? var.request_config : {}

#   rest_api_id          = lookup(each.value, "rest_api_id", var.api_id)
#   resource_id          = lookup(each.value, "resource_id", var.resource_id)
#   http_method          = aws_api_gateway_method.options_method[each.key].http_method
#   cache_key_parameters = []
#   cache_namespace      = lookup(each.value, "integration_cache_namespace", "")
#   passthrough_behavior = "NEVER"
#   request_parameters   = {}
#   type                 = "MOCK"
#   content_handling     = "CONVERT_TO_TEXT"
#   request_templates = {
#     "application/json" = jsonencode(
#       {
#         statusCode = 200
#       }
#     )
#   }
# }
# resource "aws_api_gateway_integration_response" "options_integration_response" {
#   for_each = var.enable_option_method ? var.request_config : {}

#   rest_api_id        = lookup(each.value, "rest_api_id", var.api_id)
#   resource_id        = lookup(each.value, "resource_id", var.resource_id)
#   http_method        = aws_api_gateway_method.options_method[each.key].http_method
#   status_code        = aws_api_gateway_method_response.options_200[each.key].status_code
#   response_templates = { "application/json" = "" }
#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Origin"  = "'*'"
#     "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
#     "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,DELETE,GET,HEAD,PATCH,POST,PUT'"
#   }

# }
