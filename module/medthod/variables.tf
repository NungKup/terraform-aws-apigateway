variable "api_id" {
  type = string
}
variable "resource_id" {
  type = string
}
variable "vpc_link" {
  type    = string
  default = null
}
variable "api_authorizer_id" {
  type    = string
  default = null
}
variable "http_method" { default = "" }
variable "authorization" { default = "NONE" }
variable "authorization_scopes" { default = null }
variable "api_key_required" { default = false }
variable "request_models" { default = { "application/json" = "Empty" } }
variable "request_validator_id" { default = null }
variable "request_parameters" { default = {} }

variable "integration_http_method" { default = "" }
variable "integration_type" { default = "AWS_PROXY" }
variable "integration_connection_type" { default = "INTERNET" }
variable "integration_uri" { default = "" }
variable "integration_credentials" { default = "" }
variable "integration_request_parameters" { default = {} }
variable "integration_request_templates" { default = {} }
variable "integration_passthrough_behavior" { default = null }
variable "integration_cache_key_parameters" { default = [] }
variable "integration_cache_namespace" { default = "" }
variable "integration_content_handling" { default = null }
variable "integration_timeout_milliseconds" { default = 9000 }

variable "status_code" { default = null }
variable "method_response_models" { default = {} }
variable "method_response_parameters" { default = {} }

variable "selection_pattern" { default = null }
variable "integration_response_parameters" { default = { "application/json" = "" } }
variable "integration_response_templates" { default = {} }
variable "enable_resource" {
  type    = bool
  default = false
}

variable "enable_status_400_500" {
  type    = bool
  default = false
}
variable "method_response_models_400" { default = {} }
variable "method_response_parameters_400" { default = {} }
variable "method_response_models_500" { default = {} }
variable "method_response_parameters_500" { default = {} }

variable "selection_pattern_400" { default = null }
variable "integration_response_parameters_400" { default = { "application/json" = "" } }
variable "integration_response_templates_400" { default = {} }
variable "integration_content_handling_400" { default = null }

variable "selection_pattern_500" { default = null }
variable "integration_response_parameters_500" { default = { "application/json" = "" } }
variable "integration_response_templates_500" { default = {} }
variable "integration_content_handling_500" { default = null }


# http_method
# authorization
# authorization_scopes
# api_key_required
# request_models
# request_validator_id
# request_parameters

# integration_http_method
# integration_type
# integration_connection_type
# integration_uri
# integration_credentials
# integration_request_parameters
# integration_request_templates
# integration_passthrough_behavior
# integration_cache_key_parameters
# integration_cache_namespace
# integration_content_handling
# integration_timeout_milliseconds

# status_code
# method_response_models
# method_response_parameters

# selection_pattern
# integration_response_parameters
# integration_response_templates
# integration_content_handling



# variable "request_config" {
#   type    = any
#   default = {}
# }
# variable "response_config" {
#   type    = any
#   default = {}
# }
# variable "enable_resource" {
#   type = bool
#   # default = false
# }

