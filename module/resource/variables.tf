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

variable "api_id" {
  type = string
}

variable "api_parend_id" {
  type = string
}
variable "enable_parent" {
  type    = bool
  default = false
}
variable "enable_resource" {
  type    = bool
  default = false
}
variable "vpc_link" {
  type    = string
  default = ""
}
variable "model_config" {
  type    = any
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
