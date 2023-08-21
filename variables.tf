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
  default = null
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
  type = string
}
variable "vpc_link_description" {
  type    = string
  default = null
}
variable "resource_config" {
  type    = any
  default = {}
}
variable "enable_model_count" {
  type    = bool
  default = false
}
