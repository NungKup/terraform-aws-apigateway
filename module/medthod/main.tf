resource "aws_api_gateway_method" "default" {
  count = var.enable_resource ? 1 : 0

  rest_api_id          = var.api_id
  resource_id          = var.resource_id
  http_method          = var.http_method          # ""
  authorization        = var.authorization        # NONE
  authorizer_id        = var.api_authorizer_id    # null
  authorization_scopes = var.authorization_scopes #null
  api_key_required     = var.api_key_required     # null
  request_models       = var.request_models       # { "application/json" = "Empty" })
  request_validator_id = var.request_validator_id # null
  request_parameters   = var.request_parameters   # {}
}

resource "aws_api_gateway_integration" "default" {
  count = var.enable_resource ? 1 : 0

  rest_api_id             = var.api_id
  resource_id             = var.resource_id
  http_method             = var.http_method                 #""
  integration_http_method = var.integration_http_method     #null
  type                    = var.integration_type            # AWS_PROXY
  connection_type         = var.integration_connection_type # INTERNET
  connection_id           = var.integration_connection_type == "VPC_LINK" ? var.vpc_link : ""
  uri                     = var.integration_uri                  #"")
  credentials             = var.integration_credentials          # "")
  request_parameters      = var.integration_request_parameters   # {})
  request_templates       = var.integration_request_templates    # {})
  passthrough_behavior    = var.integration_passthrough_behavior #null)
  cache_key_parameters    = var.integration_cache_key_parameters #[])
  cache_namespace         = var.integration_cache_namespace      # "") #"%{~for v in aws_api_gateway_resource.default~}${~v.id~}%{~endfor~}"
  content_handling        = var.integration_content_handling     #null)
  timeout_milliseconds    = var.integration_timeout_milliseconds #9000)
}

resource "aws_api_gateway_method_response" "default" {
  count = var.enable_resource ? 1 : 0

  rest_api_id         = var.api_id
  resource_id         = var.resource_id
  http_method         = aws_api_gateway_method.default[count.index].http_method
  status_code         = var.status_code                #", null)              #"%{~for i, v in each.value.status_code~}${~v~}%{~if i < length(v)~}v%{~else~}200%{~endif~}%{~endfor~}" # Terraform Status 200,400,500
  response_models     = var.method_response_models     #", {})     #"%{~for i, v in each.value.method_response_models~}${~v~}%{~if i < length(v)~}v%{~else~}{}%{~endif~}%{~endfor~}"     #
  response_parameters = var.method_response_parameters #", {} #"%{~for i, v in each.value.method_response_parameters~}${~v~}%{~if i < length(v)~}v%{~else~}{}%{~endif~}%{~endfor~}" #
}

resource "aws_api_gateway_integration_response" "default" {
  count = var.enable_resource ? 1 : 0

  rest_api_id         = var.api_id
  resource_id         = var.resource_id
  http_method         = aws_api_gateway_method.default[count.index].http_method
  status_code         = var.status_code                     #", null)
  selection_pattern   = var.selection_pattern               #", null)
  response_parameters = var.integration_response_parameters #", {})                         #"%{~for i, v in each.value.integration_response_parameters~}${~v~}%{~if i < length(v)~}v%{~else~}{}%{~endif~}%{~endfor~}"
  response_templates  = var.integration_response_templates  #", { "application/json" = "" }) #"%{~for i, v in each.value.integration_response_templates~}${~v~}%{~if i < length(v)~}v%{~else~}{}%{~endif~}%{~endfor~}"
  content_handling    = var.integration_content_handling    #", null)                          #"%{~for i, v in each.value.integration_content_handling~}${~v~}%{~if i < length(v)~}v%{~else~}null%{~endif~}%{~endfor~}"
}

## Enable Status Code 400 And 500
# Response 400 -------
resource "aws_api_gateway_method_response" "method_response_400" {
  count = var.enable_resource && var.enable_status_400_500 ? 1 : 0

  rest_api_id         = var.api_id
  resource_id         = var.resource_id
  http_method         = aws_api_gateway_method.default[count.index].http_method
  status_code         = "400"
  response_models     = var.method_response_models_400 #", {})     #"%{~for i, v in each.value.method_response_models~}${~v~}%{~if i < length(v)~}v%{~else~}{}%{~endif~}%{~endfor~}"     #
  response_parameters = var.method_response_parameters_400
}

resource "aws_api_gateway_integration_response" "isearch_integration_400" {
  count = var.enable_resource && var.enable_status_400_500 ? 1 : 0

  rest_api_id         = var.api_id
  resource_id         = var.resource_id
  http_method         = aws_api_gateway_method.default[count.index].http_method
  status_code         = "400"
  selection_pattern   = var.selection_pattern_400
  response_parameters = var.integration_response_parameters_400
  response_templates  = var.integration_response_templates_400
  content_handling    = var.integration_content_handling_400
}

# Response 500 -------
resource "aws_api_gateway_method_response" "method_response_500" {
  count = var.enable_resource && var.enable_status_400_500 ? 1 : 0

  rest_api_id         = var.api_id
  resource_id         = var.resource_id
  http_method         = aws_api_gateway_method.default[count.index].http_method
  status_code         = "500"
  response_models     = var.method_response_models_500 #", {})     #"%{~for i, v in each.value.method_response_models~}${~v~}%{~if i < length(v)~}v%{~else~}{}%{~endif~}%{~endfor~}"     #
  response_parameters = var.method_response_parameters_500
}

resource "aws_api_gateway_integration_response" "isearch_integration_500" {
  count = var.enable_resource && var.enable_status_400_500 ? 1 : 0

  rest_api_id         = var.api_id
  resource_id         = var.resource_id
  http_method         = aws_api_gateway_method.default[count.index].http_method
  status_code         = "500"
  selection_pattern   = var.selection_pattern_500
  response_parameters = var.integration_response_parameters_500
  response_templates  = var.integration_response_templates_500
  content_handling    = var.integration_content_handling_500
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
