variable "enable_private_api" {
  type    = bool
  default = true
}
variable "enable_vpc_link" {
  type    = bool
  default = true
}
variable "nlb_target_arn" {
  type    = list(string)
  default = []
}
variable "name" {
  type = string
}
variable "description" {
  type    = string
  default = null
}
variable "minimum_compression_size" {
  default = -1
}
variable "api_key_source" {
  type    = string
  default = "HEADER"
}
variable "endpoint_configuration" {
  type    = any
  default = {}
}
variable "vpc_id" {
  type = string
}
variable "vpc_link_name" {
  type    = string
  default = ""
}
variable "vpc_link_description" {
  type    = string
  default = null
}
# variable "resource" {
#   type    = any
#   default = {}
# }
variable "resource_config" {
  type    = any
  default = {}
}
variable "resource_parent_config" {
  type    = any
  default = {}
}
variable "enable_model_count" {
  type    = bool
  default = false
}
variable "enable_parent" {
  type    = bool
  default = false
}
# variable "enable_resource" {
#   type    = bool
#   default = false
# }
variable "deploy" {
  default = {}
}
variable "stage" {
  default = {}
}
variable "enable_create_double_medthod" {
  type    = bool
  default = false
}
variable "resource_double_medthod" {
  type    = any
  default = {}
}
variable "enable_stage_log" {
  type    = bool
  default = false
}
variable "enable_method_setting" {
  type    = bool
  default = false
}

variable "method_setting" {
  type    = any
  default = {}
}
variable "api_key" {
  default = {}
}
variable "enable_api_key" {
  default = false
}
variable "enable_domain_name" {
  default = false
}
variable "domain_name" {
  default = {}
}
