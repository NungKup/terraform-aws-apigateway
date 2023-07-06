### API Gateway Rest API
variable "enable_apigw" {
  description = "Controls if API Gateway should be created"
  type        = bool
  default     = true
}
variable "enable_apigw_private" {
  type    = bool
  default = false
}

variable "enable_resource_path" {
  type    = bool
  default = true
}
### API Gateway Model
variable "enable_model_count" {
  type    = bool
  default = false
}
### API Gateway Option Method
variable "enable_option_method" {
  type    = bool
  default = false
}
### API Gateway VPC Link
variable "enable_vpc_link" {
  type    = bool
  default = false
}
### API Gateway Api Key
variable "enable_api_key" {
  type    = bool
  default = false
}
### API Gateway authorizer
variable "enable_authorizer" {
  type    = bool
  default = false
}
## API Gateway deployment_enabled
variable "deployment_enabled" {
  type    = bool
  default = false
}
## enable_access_log_setting
variable "enable_access_log_setting" {
  type    = bool
  default = false
}

variable "vpc_id" {
  type    = string
  default = ""
}
variable "apigw_name" {
  type    = any
  default = {}
}
variable "resource_path" {
  type    = any
  default = {}
}
variable "method_response" {
  type    = any
  default = {}
}
# variable "config_model" {
#   type    = any
#   default = {}
# }
variable "stage_deploy" {
  type    = any
  default = {}
}
variable "vpc_link" {
  type    = any
  default = {}
}
variable "api_key" {
  type    = any
  default = {}
}
variable "authorizer" {
  type    = any
  default = {}
}
variable "access_log_settings" {
  type    = any
  default = {}
}
